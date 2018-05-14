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
import FRP.Event (Event, subscribe)

-- | Possibly this should be a data that includes a magical value TAB_ID_NONE
-- | See https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/tabs/TAB_ID_NONE
newtype TabID = TabID Int

instance showTabID :: Show TabID where
  show (TabID id) = "TabID " <> show id

-- | The browser also supplies integer windowId
type OnActivatedParameters =
  { tabId :: TabID
  }

type Tab =
  { active :: Boolean
  , windowId :: Int
  , url :: Maybe String
  }

foreign import onUpdated :: Event Int
foreign import onActivated :: Event OnActivatedParameters

foreign import getTabImpl
  :: (forall a. a -> Maybe a)
  -> (forall a. Maybe a)
  -> TabID -> Promise Tab

getTab = getTabImpl Just Nothing

log_onUpdated :: forall eff. Int -> Eff ( console :: CONSOLE | eff) Unit
log_onUpdated tabId = log ("onUpdated " <> show tabId)

log_onActivated :: forall eff. OnActivatedParameters -> Eff ( console :: CONSOLE | eff) Unit
log_onActivated {tabId} = log ("onActivated tabId=" <> show tabId)

go = launchAff do
  x <- Promise.toAff (getTab (TabID 1))
  liftEff $ logShow x.windowId
  y <- Promise.toAff (getTab (TabID 2))
  liftEff $ logShow y.windowId
  liftEff $ logShow y.active
  liftEff $ logShow (maybe "EMPTY" (drop 3) y.url)

main = do
  _ <- subscribe onUpdated log_onUpdated
  _ <- subscribe onActivated log_onActivated
  _ <- go
  pure unit
