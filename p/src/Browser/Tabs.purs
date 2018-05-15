module Browser.Tabs
  ( onUpdated
  , onActivated
  , OnActivatedParameters
  , TabID(..)
  , get
  ) where

import Prelude
import Data.Maybe (Maybe(..))
import FRP.Event (Event)
import Control.Promise (Promise)

-- | Possibly this should be a data that includes a magical value TAB_ID_NONE
-- | See https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/tabs/TAB_ID_NONE
newtype TabID = TabID Int

instance showTabID :: Show TabID where
  show (TabID id) = "TabID " <> show id

-- | The browser also supplies integer windowId
type OnActivatedParameters =
  { tabId :: TabID
  }

-- | XXX: Add title here
-- | XXX: Remove unused properties
type Tab =
  { active :: Boolean
  , windowId :: Int
  , url :: Maybe String
  }

foreign import onUpdated :: Event TabID
foreign import onActivated :: Event OnActivatedParameters

foreign import getImpl
  :: (forall a. a -> Maybe a)
  -> (forall a. Maybe a)
  -> TabID -> Promise Tab

get :: TabID -> Promise Tab
get = getImpl Just Nothing
