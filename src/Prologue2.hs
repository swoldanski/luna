{-# LANGUAGE NoMonomorphismRestriction #-} -- FIXME: remove

module Prologue2 (module Prologue2, module X) where


-- === Data types === --
import Prologue.Data.Basic              as X
import Prologue.Data.Num                as X
import Prologue.Data.Show               as X
import Data.Function                    as X (id, const, (.), flip, ($), (&), on)
import GHC.Generics                     as X (Generic)
import Data.Text                        as X (Text)

-- === Monads === --
import Prologue.Control.Monad
import Prologue.Control.Monad.IO        as X
import Prologue.Control.Monad.Primitive as X
import Control.Applicative              as X ( Applicative, pure, (<*>), (*>), (<*), (<$>), (<$), (<**>), liftA, liftA2, liftA3, optional
                                             , Alternative, empty, (<|>), some, many
                                             , ZipList
                                             )
import Control.Monad.Fix                as X (MonadFix, mfix, fix)
import Control.Monad.Trans.Class        as X (MonadTrans, lift)
import Control.Monad.Identity           as X (Identity, runIdentity)
import Control.Monad.Trans.Identity     as X (IdentityT, runIdentityT)

-- === Basic typeclasses === --
import Prologue.Data.Foldable           as X
import Prologue.Data.Traversable        as X
import Prologue.Data.Bifunctor          as X

-- === Errors === --
import Control.Exception.Base           as X (assert)
import Prologue.Control.Error           as X

-- === Conversions === --
import Data.Coerce                      as X (Coercible, coerce)

-- === Exts === --
import GHC.Exts                         as X (lazy, inline) -- + oneShot after base update

-- === Types === --
import Data.Type.Equality               as X ((:~:), type(==), TestEquality, testEquality) -- + (~~), (:~~:) after base update


-- === Debugging === --
import Debug.Trace                      as X (trace, traceShow)
import GHC.Exts                         as X (breakpoint, breakpointCond)
import GHC.Stack                        as X ( CallStack, HasCallStack, callStack, emptyCallStack, freezeCallStack, getCallStack, popCallStack
                                             , prettyCallStack, pushCallStack, withFrozenCallStack, currentCallStack)
import GHC.TypeLits                     as X (TypeError, ErrorMessage(Text, ShowType, (:<>:), (:$$:)))

-- === Quasi Quoters == --
import Prologue.Data.String.QQ          as X (str, rawStr, txt)


-- === Typelevel === --
import GHC.TypeLits                     as X (Nat, Symbol, type (-), type (+), type (*), type (^), CmpNat, CmpSymbol) -- someSymbolVal and typelits reify?
import Type.Known                       as X (KnownType, KnownTypeVal, fromType)
import Data.Kind                        as X (Type, Constraint)



import qualified Prelude as Prelude
import Prelude                   as X ( Enum (succ, pred, toEnum, fromEnum, enumFrom, enumFromThen, enumFromTo, enumFromThenTo)
                                      , Bounded (minBound, maxBound)
                                      , Functor (fmap, (<$)), (<$>)
                                      , until, asTypeOf, error, errorWithoutStackTrace, undefined
                                      , seq, ($!)
                                      , map, filter, head, last, tail, init, null, length, (!!), reverse
                                      , scanl, scanl1, scanr, scanr1
                                      , iterate, repeat, cycle
                                      , take, drop, splitAt, takeWhile, dropWhile, span, break
                                      , notElem, lookup
                                      , zip, zip3, zipWith, zipWith3, unzip, unzip3
                                      , lines, words, unwords
                                      , ReadS, Read (readsPrec, readList), reads, readParen, read, lex
                                      )




import Control.Comonad            as X (Comonad, extract, duplicate, extend, (=>=), (=<=), (<<=), (=>>))
import Control.Comonad            as X (ComonadApply, (<@>), (<@), (@>), (<@@>), liftW2, liftW3)

import Data.Ix                    as X (Ix, range, inRange, rangeSize)
import qualified Data.Ix          as Ix

import Data.Container.Class       as X (Container, Index, Item)
import Data.Container.List        as X (FromList, fromList, ToList, toList, asList, IsList)
import Data.Convert               as X
import Data.Functor.Utils         as X
import Data.Impossible            as X
--import Data.Layer_OLD.Cover_OLD           as X
import Data.String.Class          as X (IsString (fromString), ToString (toString))

import Data.Tuple.Curry           as X (Curry)
import Data.Tuple.Curry.Total     as X (Uncurried', Curry', curry')
import Data.Typeable              as X (Typeable, Proxy(Proxy), typeOf, typeRep, TypeRep)
import Data.Typeable.Proxy.Abbr   as X (P, p)
import Type.Operators             as X -- (($), (&))
import Type.Show                  as X (TypeShow, showType, showType', printType, ppPrintType, ppShowType)
import Type.Monoid                as X (type (<>))
import Type.Applicative           as X (type (<$>), type (<*>))
import Type.Error                 as X
import Control.Monad.Catch        as X (MonadMask, MonadCatch, MonadThrow, throwM, catch, mask, uninterruptibleMask, mask_, uninterruptibleMask_, catchAll, catchIOError, catchJust, catchIf)
import Text.Read                  as X (readPrec) -- new style Read class implementation

import Data.Constraints           as X (Constraints)
import Unsafe.Coerce              as X (unsafeCoerce)
import Prologue.Data.Typeable     as X
import Control.Exception          as X (Exception, SomeException, toException, fromException, displayException)
import Data.Data                  as X (Data)
import Data.Functor.Classes       as X (Eq1, eq1, Ord1, compare1, Read1, readsPrec1, Show1, showsPrec1)
import Data.List.NonEmpty         as X (NonEmpty ((:|)))
import Control.Monad.Fail         as X (MonadFail, fail)

-- === Lenses === --
import Control.Lens.Wrapped       as X (Wrapped, _Wrapped, _Unwrapped, _Wrapping, _Unwrapping, _Wrapped', _Unwrapped', _Wrapping', _Unwrapping', op, ala, alaf)
import Control.Lens.Wrapped.Utils as X
import Control.Lens.Utils         as X hiding (lazy)

-- === Data types === --



-- === Bool === --
import Control.Conditional        as X (if', ifM, unless, unlessM, notM, xorM, ToBool, toBool)

-- === Maybe === --
import Data.Maybe                 as X (mapMaybe, catMaybes, fromJust, fromMaybe, isJust, isNothing)
import Control.Error.Util         as X (maybeT)
import Control.Monad.Trans.Maybe  as X (MaybeT, runMaybeT, mapMaybeT, maybeToExceptT, exceptToMaybeT)

-- === Either === --
import Control.Monad.Trans.Either as X (EitherT(EitherT), runEitherT, eitherT, hoistEither, left, right, swapEitherT, mapEitherT)
import Data.Either.Combinators    as X (isLeft, isRight, mapLeft, mapRight, whenLeft, whenRight, leftToMaybe, rightToMaybe, swapEither)
import Data.Either                as X (either, partitionEithers)




import Data.Copointed             as X (Copointed, copoint)
import Data.Pointed               as X (Pointed, point)

-- Tuple handling
import Prologue.Data.Tuple        as X

-- Data description
import Prologue.Data.Default      as X
import Data.Monoids               as X

-- Normal Forms
import Prologue.Control.DeepSeq   as X

-- Missing instances
import Data.Default.Instances.Missing ()

import Data.Functor.Compose

import qualified Data.Traversable                   as Traversable



-- Placeholders
import Prologue.Placeholders as X (notImplemented, todo, fixme, placeholder, placeholderNoWarning, PlaceholderException(..))

import qualified Data.List as List
import           Data.List as X (sort)



unlines :: (IsString a, Monoid a, Foldable f) => f a -> a
unlines = intercalate "\n" ; {-# INLINE unlines #-}



-- Ix

rangeIndex :: Ix a => (a, a) -> a -> Int
rangeIndex = Ix.index



replicate :: (Num a, Eq a, Enum a, Ord a) => a -> t -> [t]
replicate 0 _ = []
replicate i c = if (i < 0) then [] else c : replicate (pred i) c


swap :: (a,b) -> (b,a)
swap (a,b) = (b,a)

fromJustM :: (Monad m, MonadFail m) => Maybe a -> m a
fromJustM Nothing  = fail "Prelude.fromJustM: Nothing"
fromJustM (Just x) = return x


whenLeft_ :: Monad m => Either a b -> m () -> m ()
whenLeft_ e f = whenLeft e (const f)

whenRight_ :: Monad m => Either a b -> m () -> m ()
whenRight_ e f = whenRight e $ const f

whenRightM :: Monad m => m (Either a b) -> (b -> m ()) -> m ()
whenRightM a f = do
    a' <- a
    whenRight a' f

withRightM :: Monad m => (r -> m (Either l r')) -> Either l r -> m (Either l r')
withRightM f = \case
    Left  l -> return $ Left l
    Right r -> f r

($>) :: (Functor f) => a -> f b -> f b
($>) =  fmap . flip const


withJust :: (Monad m, Mempty out) => Maybe a -> (a -> m out) -> m out
withJust ma f = case ma of
    Nothing -> return mempty
    Just a  -> f a

withJust_ :: Monad m => Maybe a -> (a -> m b) -> m ()
withJust_ ma f = case ma of
    Nothing -> return ()
    Just a  -> void $ f a

withJustM :: (Monad m, Mempty out) => m (Maybe a) -> (a -> m out) -> m out
withJustM ma f = do
    a <- ma
    withJust a f

withJustM_ :: Monad m => m (Maybe a) -> (a -> m b) -> m ()
withJustM_ ma f = do
    a <- ma
    withJust_ a f

lift2 :: (Monad (t1 m), Monad m, MonadTrans t, MonadTrans t1)
      => m a -> t (t1 m) a
lift2 = lift . lift


lift3 :: (Monad (t1 (t2 m)), Monad (t2 m), Monad m, MonadTrans t, MonadTrans t1, MonadTrans t2)
      => m a -> t (t1 (t2 m)) a
lift3 = lift . lift2


--
-- switchM :: Monad m => m Bool -> a -> a -> m a
-- switchM cond fail ok = do
--   c <- cond
--   return $ if c then ok else fail




show' :: (Show a, IsString s) => a -> s
show' = fromString . Prelude.show

foldlDef :: (a -> a -> a) -> a -> [a] -> a
foldlDef f d = \case
    []     -> d
    (x:xs) -> foldl f x xs



ifElseId :: Bool -> (a -> a) -> (a -> a)
ifElseId cond a = if cond then a else id


fromMaybeM :: Monad m => m a -> Maybe a -> m a
fromMaybeM ma = \case
    Just a  -> return a
    Nothing -> ma

fromMaybeWith :: b -> (a -> b) -> Maybe a -> b
fromMaybeWith b f = \case
    Just  a -> f a
    Nothing -> b

evalWhenLeft :: Monad m => m (Either l r) -> m () -> m (Either l r)
evalWhenLeft me f = do
    e <- me
    case e of
        Left  _ -> e <$ f
        Right _ -> return e

evalWhenRight :: Monad m => m (Either l r) -> m () -> m (Either l r)
evalWhenRight me f = do
    e <- me
    case e of
        Left  _ -> e <$ f
        Right _ -> return e


infixl 1 <!>
evalWhenWrong, (<!>) :: (Monad m, CanBeWrong a) => m a -> m () -> m a
(<!>) = evalWhenWrong
evalWhenWrong ma f = do
    a <- ma
    if isWrong a then a <$ f
                 else return a

class CanBeWrong a where
    isWrong :: a -> Bool

instance CanBeWrong (Maybe  a)   where isWrong = isNothing
instance CanBeWrong (Either l r) where isWrong = isLeft

justIf :: Bool -> a -> Maybe a
justIf b a = if b then Just a else Nothing


guarded :: Alternative f => Bool -> a -> f a
guarded b a = case b of True  -> pure a
                        False -> empty




composed :: Iso' (f (g a)) (Compose f g a)
composed = iso Compose getCompose



-- This is just a garbage-util for dummy Prelude show implementation
-- For more information look here: https://hackage.haskell.org/package/base-4.9.0.0/docs/Text-Show.html
app_prec :: Int
app_prec = 10

showsPrec' = showsPrec (succ app_prec)
showParen' d = showParen (d > app_prec)


-- === MonadTrans === --

type MonadTransInvariants  t m = (Monad m, Monad (t m), MonadTrans t)
type MonadTransInvariants' t m = (Monad m, Monad (t m), MonadTrans t, PrimState m ~ PrimState (t m))

type EqPrims m n = (PrimState m ~ PrimState n)



copointed :: (Pointed t, Copointed t) => Iso (t a) (t b) a b
copointed = iso copoint point

pointed :: (Pointed t, Copointed t) => Iso a b (t a) (t b)
pointed = from copointed

copointed' :: (Copointed t, Functor t) => Lens (t a) (t b) a b
copointed' = lens copoint (\ta b -> fmap (const b) ta)




if_ :: (ToBool cond, Mempty a) => cond -> a -> a
if_ p s = if toBool p then s else mempty

when   :: (Applicative f, ToBool cond)           =>   cond -> f a -> f ()
whenM  :: (Monad m      , ToBool cond)           => m cond -> m a -> m ()
when'  :: (Applicative f, ToBool cond, Mempty a) =>   cond -> f a -> f a
whenM' :: (Monad m      , ToBool cond, Mempty a) => m cond -> m a -> m a
when   p s = if toBool  p then void s else pure ()
when'  p s = if toBool  p then s      else pure mempty
whenM  p s = flip when  s =<< p
whenM' p s = flip when' s =<< p


infixl 4 |$
(|$) :: (a -> b) -> a -> (a, b)
f |$ a = (a, f a)

infixl 4 $|
($|) :: (a -> b) -> a -> (b, a)
f $| a = (f a, a)

infixl 4 <|$>
(<|$>) :: Functor f => (a -> b) -> f a -> f (a, b)
f <|$> a = (f |$) <$> a

infixl 4 <$|>
(<$|>) :: Functor f => (a -> b) -> f a -> f (b, a)
f <$|> a = (f $|) <$> a



infixl 4 <|$$>
infixl 4 <$$|>
(<|$$>) :: (Traversable t, Monad m) => (a -> m b) -> t a -> m (t (a, b))
(<$$|>) :: (Traversable t, Monad m) => (a -> m b) -> t a -> m (t (b, a))
f <|$$> ta = (\a -> (a,) <$> f a) <$$> ta
f <$$|> ta = (\a -> (,a) <$> f a) <$$> ta







partitionMaybeTaggedList :: [(a, Maybe b)] -> ([a], [(a,b)])
partitionMaybeTaggedList = \case
    []             -> ([], [])
    ((a, mb) : ls) -> partitionMaybeTaggedList ls & case mb of
        Nothing -> _1 %~ (a:)
        Just b  -> _2 %~ ((a,b):)



elem' :: Eq a => a -> [a] -> Bool
elem' = elem

maybeRead :: Read a => String -> Maybe a
maybeRead s = case reads s of
    [a] -> Just $ fst a
    _   -> Nothing




tryReads :: forall s' s a. (Read a, Convertible' s String) => s -> Either String a
tryReads s = case reads (convert' s) of
    [(a,[])]  -> Right a
    ((_,s):_) -> Left  s
    _         -> Left "No read"
