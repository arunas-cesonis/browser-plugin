module Main where

import Prelude
import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)

import FRP (FRP)
import FRP.Event (Event, subscribe)

newtype TabID = TabID Int

instance showTabID :: Show TabID where
  show (TabID id) = "TabID " <> show id

type OnActivatedParameters =
  { tabId :: TabID
  , windowId :: Int
  }

foreign import onUpdated :: Event Int
foreign import onActivated :: Event OnActivatedParameters

log_onUpdated :: forall eff. Int -> Eff ( console :: CONSOLE | eff) Unit
log_onUpdated tabId = log ("onUpdated " <> show tabId)

log_onActivated :: forall eff. OnActivatedParameters -> Eff ( console :: CONSOLE | eff) Unit
log_onActivated {tabId, windowId} = log ("onActivated tabId=" <> show tabId <> " windowId=" <> show windowId)

main = do
  _ <- subscribe onUpdated log_onUpdated
  _ <- subscribe onActivated log_onActivated
  pure unit
