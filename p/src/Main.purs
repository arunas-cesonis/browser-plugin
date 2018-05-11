module Main where

import Prelude
import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Eff.Console (CONSOLE, log)

foreign import data BROWSER :: Effect

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Hello sailor!"
