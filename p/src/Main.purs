module Main where

import Prelude
import Data.Maybe (Maybe(..), maybe)
import Data.String
import Control.Monad.Aff
import Control.Monad.Eff.Class
import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Control.Promise as Promise
import Control.Promise (Promise)

import FRP (FRP)
import FRP.Event (subscribe)
import Browser.Tabs as Tabs

log_onUpdated :: forall eff. Int -> Eff ( console :: CONSOLE | eff) Unit
log_onUpdated tabId = log ("onUpdated " <> show tabId)

log_onActivated :: forall eff. Tabs.OnActivatedParameters -> Eff ( console :: CONSOLE | eff) Unit
log_onActivated {tabId} = log ("onActivated tabId=" <> show tabId)

-- | XXX: Hook these up in log_ functions with calls to backend via affjax
go = launchAff do
  x <- Promise.toAff (Tabs.get (Tabs.TabID 1))
  liftEff $ logShow x.windowId
  y <- Promise.toAff (Tabs.get (Tabs.TabID 2))
  liftEff $ logShow y.windowId
  liftEff $ logShow y.active
  liftEff $ logShow (maybe "EMPTY" (drop 3) y.url)

main = do
  _ <- subscribe Tabs.onUpdated log_onUpdated
  _ <- subscribe Tabs.onActivated log_onActivated
  _ <- go
  pure unit
