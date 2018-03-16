{-# LANGUAGE TemplateHaskell #-}
module Foreign.Storable.Deriving (deriveStorable) where

import Prologue

import Control.Lens                (view, _2, _3)
import Foreign.Storable            (Storable)
import GHC.Num
import Language.Haskell.TH         hiding (clause)
import Language.Haskell.TH.Builder
import Language.Haskell.TH.Lib     hiding (clause)

import qualified Data.List.NonEmpty  as NonEmpty
import qualified Foreign.Storable    as Storable
import qualified Language.Haskell.TH as TH


--------------------------------------
-- === TH info extracting utils === --
--------------------------------------

concretizeType :: TH.Type -> TH.Type
concretizeType = \case
    ConT n   -> ConT n
    VarT _   -> ConT ''Int
    AppT l r -> AppT (concretizeType l) (concretizeType r)
    _        -> error "***error*** deriveStorable: only reasonably complex types supported"

-- | Instantiate all the free type variables to Int for a consturctor
extractConcreteTypes :: TH.Con -> [TH.Type]
extractConcreteTypes = \case
    NormalC n bts -> (concretizeType . view _2) <$> bts
    RecC    n bts -> (concretizeType . view _3) <$> bts
    _ -> error "***error*** deriveStorable: type not yet supported"



-------------------------------------
-- === TH convenience wrappers === --
-------------------------------------

sizeOfType :: TH.Type -> TH.Exp
sizeOfType = app (var 'Storable.sizeOf) . (var 'undefined -::)

sizeOfInt :: TH.Exp
sizeOfInt = sizeOfType $ cons' ''Int

op :: Name -> TH.Exp -> TH.Exp -> TH.Exp
op = app2 . var

plus, mul :: TH.Exp -> TH.Exp -> TH.Exp
plus = op '(+)
mul  = op '(*)

intLit :: Integer -> TH.Exp
intLit = LitE . IntegerL

undefinedAsInt :: TH.Exp
undefinedAsInt = var 'undefined -:: cons' ''Int

conFieldSizes :: TH.Con -> [TH.Exp]
conFieldSizes = fmap sizeOfType . extractConcreteTypes

sizeOfCon :: TH.Con -> TH.Exp
sizeOfCon con
    | conArity con > 0 = unsafeFoldl1 plus $ conFieldSizes con
    | otherwise        = intLit 0

align :: TH.Exp
align = app (var 'Storable.alignment) undefinedAsInt

whereClause :: Name -> TH.Exp -> TH.Dec
whereClause n e = ValD (var n) (NormalB e) mempty

wildCardClause :: TH.Exp -> TH.Clause
wildCardClause expr = clause [WildP] expr mempty


--------------------------------
-- === Main instance code === --
--------------------------------

-- | Generate the `Storable` instance for a type.
--   The constraint is that all of the fields of
--   the type's constructor must be Ints.
deriveStorable :: Name -> Q [TH.Dec]
deriveStorable ty = do
    TypeInfo tyConName tyVars cs <- getTypeInfo ty
    decs <- sequence [pure $ genSizeOf cs, pure genAlignment, genPeek cs, genPoke cs]
    let inst = classInstance ''Storable tyConName tyVars decs
    pure [inst]


-------------------------------
-- === Method generators === --
-------------------------------

-- | Generate the offsets for a constructor (also pures the names of the variables in wheres).
--   Example:
--   > data T = Cons x y
--   >
--   > [...] where off0 = 0
--   >             off1 = sizeOf (undefined :: Int)
--   >             off2 = off1 + sizeOf (undefined :: x)
--   >             off3 = off2 + sizeOf (undefined :: y)
genOffsets :: TH.Con -> Q (NonEmpty Name, NonEmpty TH.Dec)
genOffsets con = do
    let fSizes  = conFieldSizes con
        arity   = length fSizes
        name i  = newName $ "off" <> show i

    name0     <- name 0
    namesList <- mapM name $ take arity [1..]
    let names = name0 :| namesList
    case names of
        n :| [] -> pure (names, whereClause n (intLit 0 -:: cons' ''Int) :| [])
        names@(n1 :| (n2:ns)) -> do
            let off0D   = whereClause n1 $ intLit 0 -:: cons' ''Int
                off1D   = whereClause n2 $ app (var 'Storable.sizeOf) undefinedAsInt
                headers = zip3 ns (n2:ns) fSizes

                mkDecl :: (Name, Name, TH.Exp) -> Dec
                mkDecl (declName, refName, fSize) =
                    whereClause declName (plus (var refName) fSize) -- >> where declName = refName + size

                clauses = off0D :| (off1D : fmap mkDecl headers)

            pure (names, clauses)

-- | Generate the `sizeOf` method of the `Storable` class.
--   It will pure the largest possible size of a given data type.
--   The mechanism is much like unions in C.
genSizeOf :: [TH.Con] -> TH.Dec
genSizeOf conss = FunD 'Storable.sizeOf [wildCardClause expr]
    where expr = case conss of
            []  -> intLit 0
            [c] -> sizeOfCon c
            cs  -> genSizeOfExpr cs

genSizeOfExpr :: [TH.Con] -> TH.Exp
genSizeOfExpr cs = plus maxConSize sizeOfInt
    where conSizes   = ListE $ sizeOfCon <$> cs
          maxConSize = app2 (var 'maximumDef) (intLit 0) conSizes

-- | Generate the `alignment` method of the `Storable` class.
--   It will always be the size of `Int`.
genAlignment :: TH.Dec
genAlignment = FunD 'Storable.alignment [genAlignmentClause]

genAlignmentClause :: TH.Clause
genAlignmentClause = wildCardClause $ app (var 'Storable.sizeOf) undefinedAsInt

-- | Generate the `peek` method of the `Storable` class.
--   It will behave differently for single- and multi-constructor types,
--   as well as for no-argument constructors. For details, please refer to
--   the docs for the `genPoke` method, where the memory layout is described
--   in detail.
genPeek :: [TH.Con] -> Q TH.Dec
genPeek cs = funD 'Storable.peek [genPeekClause cs]

-- | Generate the `case` expression that given a tag of the constructor
--   will perform the appropriate number of pokes.
genPeekCaseMatch :: Bool -> Name -> Integer -> TH.Con -> Q TH.Match
genPeekCaseMatch single ptr idx con = do
    (off0 :| offNames, whereCs) <- genOffsets con
    let (cName, arity)   = conNameArity con
        peekByteOffPtr   = app (var 'Storable.peekByteOff) (var ptr)
        peekByte off     = app peekByteOffPtr $ var off
        appPeekByte t x  = op '(<*>) t $ peekByte x
        -- No-field constructors are a special case of just the constructor being pureed
        (firstCon, offs) = case offNames of
                (off1:os) -> (op '(<$>) (ConE cName) (peekByte $ if single then off0 else off1), os)
                _         -> (app (var 'pure) (ConE cName), [])
        body             = NormalB $ foldl appPeekByte firstCon offs
        pat              = LitP $ IntegerL idx
    pure $ TH.Match pat body (NonEmpty.toList whereCs)

-- | Generate a catch-all branch of the case to account for
--   non-exhaustive patterns warnings.
genPeekCatchAllMatch :: TH.Match
genPeekCatchAllMatch = TH.Match TH.WildP (TH.NormalB body) mempty
    where body = app (var 'error) (TH.LitE $ TH.StringL "[peek] Unrecognized constructor")

-- | Generate the `peek` clause for a single-constructor types.
--   In this case the fields are stored raw, without the tag.
genPeekSingleCons :: Name -> TH.Con -> Q TH.Clause
genPeekSingleCons ptr con = do
    TH.Match _ body whereCs <- genPeekCaseMatch True ptr 0 con
    let pat = if noArgCon con then TH.WildP else var ptr
    case body of
        TH.NormalB e  -> pure $ clause [pat] e whereCs
        TH.GuardedB _ -> fail "[genPeekSingleCons] Guarded bodies not supported"

-- Generate the `peek` method for multi-constructor data types.
genPeekMultiCons :: Name -> Name -> [TH.Con] -> Q TH.Clause
genPeekMultiCons ptr tag cs = do
    peekCases <- zipWithM (genPeekCaseMatch False ptr) [0..] cs
    let peekTag      = app (app (var 'Storable.peekByteOff) (var ptr)) (intLit 0)
        peekTagTyped = peekTag -:: app (cons' ''IO) (cons' ''Int)
        bind         = BindS (var tag) peekTagTyped
        cases        = CaseE (var tag) $ peekCases <> [genPeekCatchAllMatch]
        doE          = DoE [bind, NoBindS cases]
        pat          = if all noArgCon cs then TH.WildP else var ptr
    pure $ clause [pat] doE mempty

-- | Generate the clause for the `peek` method,
--   deciding between single- and multi-constructor implementations.
genPeekClause :: [TH.Con] -> Q TH.Clause
genPeekClause cs = do
    ptr <- newName "ptr"
    tag <- newName "tag"
    case cs of
        []  -> fail "[genPeekClause] Phantom types not supported"
        [c] -> genPeekSingleCons ptr c
        cs  -> genPeekMultiCons ptr tag cs

-- | Generate a `poke` method of the `Storable` class.
--   Behaves differently for single- and multi-constructor types
--   as well as for constructors with no arguments.
--
--   When the type has a single constructor, we will just store
--   the elements in the memory one after the other.
--   Example: `data Bar = Bar Int Int Int` will be stored as:
--                  ----------------
--   Bar 1 10 100:  | 1 | 10 | 100 |
--                  ----------------
--
--   In the multi-constructor case we need to add a tag that will
--   encode the constructor that this value was created with.
--   Example: `data Foo = A Int | B Int | C Int` will be stored as:
--         ----------       ----------          -----------
--   A 12: | 0 | 12 | B 32: | 1 | 32 |  C 132 : | 2 | 132 |
--         ----------       ----------          -----------
genPoke :: [TH.Con] -> Q TH.Dec
genPoke conss = funD 'Storable.poke $ case conss of
    []  -> error "[genPoke] Phantom types not supported"
    [c] -> [genPokeClauseSingle c]
    cs  -> zipWith genPokeClauseMulti [0 ..] cs

-- | Generate the pattern for the `poke` method.
--   like: `poke ptr (SomeCons consArgs)`.
genPokePat :: Name -> Name -> [Name] -> [TH.Pat]
genPokePat ptr cName patVarNames =
    [var ptr, cons cName $ var <$> patVarNames]

-- | A wrapper utility for generating the poking expressions.
genPokeExpr :: Name -> NonEmpty Name -> [Name] -> TH.Exp -> TH.Exp
genPokeExpr ptr (off :| offNames) varNames firstExpr = body
    where pokeByteOffPtr = app (var 'Storable.pokeByteOff) (var ptr)
          pokeByte a     = app2 pokeByteOffPtr (var a)
          nextPoke t     = app2 (var '(>>)) t .: pokeByte
          firstPoke      = pokeByte off firstExpr
          varxps         = var <$> varNames
          body           = foldl (uncurry . nextPoke) firstPoke
                         $ zip offNames varxps

-- | Generate a `poke` clause ignoring its params and pureing unit.
genEmptyPoke :: Q TH.Clause
genEmptyPoke = pure $ clause [WildP, WildP] pureUnit mempty
    where pureUnit = app (var 'pure) (TH.ConE '())

-- | Generate a `poke` clause for single-constructor data types.
--   In this case we don't add the tag to the stored memory,
--   as it is unambiguous.
genPokeClauseSingle :: TH.Con -> Q TH.Clause
genPokeClauseSingle con = do
    let (cName, nParams) = conNameArity con
    ptr         <- newName "ptr"
    patVarNames <- newNames nParams
    -- if the constructor has no params, we will generate `poke _ _ = pure ()`
    case patVarNames of
        [] -> genEmptyPoke
        (firstP : restP) -> do
            (offNames, whereCs) <- genOffsets con
            let pat  = genPokePat  ptr cName patVarNames
                body = genPokeExpr ptr offNames restP (var firstP)
            pure $ clause pat body (NonEmpty.toList whereCs)

-- | Generate a `poke` clause for multi-constructor data types.
--   In this case we add a tag to the stored memory, so that
--   when poking we know which constructor to choose.
genPokeClauseMulti :: Integer -> TH.Con -> Q TH.Clause
genPokeClauseMulti idx con = do
    let (cName, nParams) = conNameArity con
    -- if the constructor has no params, we will generate `poke _ _ = pure ()`
    if nParams == 0 then genEmptyPoke
    else do
        ptr         <- newName "ptr"
        patVarNames <- newNames nParams
        (offNames, whereCs) <- genOffsets con
        let pat            = genPokePat ptr cName patVarNames
            idxAsInt       = convert idx -:: cons' ''Int
            body           = genPokeExpr ptr offNames patVarNames idxAsInt
        pure $ clause pat body (NonEmpty.toList whereCs)