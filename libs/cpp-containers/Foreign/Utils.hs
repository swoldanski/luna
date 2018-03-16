module Foreign.Utils where

import Control.Monad.IO.Class (MonadIO)
import Prelude


-- | Function converting the c-like Int-encoded boolean to a Haskell one.
--   Exists just for the purpose of pinning-down this simple logic.
--   Note: it's lifted to IO so that it composes nicely with IO functions.
fromCBool :: MonadIO m => Int -> m Bool
fromCBool = return . (/= 0)
{-# INLINE fromCBool #-}