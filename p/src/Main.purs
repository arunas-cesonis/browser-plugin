module Main where

import Prelude (Unit, bind, discard, pure, unit, ($), (<>))
import Data.Maybe (fromMaybe)
import Control.Monad.Aff (Aff, launchAff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (log)
import Control.Promise as Promise
import Data.Argonaut.Encode (class EncodeJson, encodeJson, (:=), (~>))
import Data.Argonaut (jsonEmptyObject)
import Network.HTTP.Affjax (AJAX, post)

import FRP.Event (subscribe)
import Browser.Tabs as Tabs

newtype Request = Request
  { url :: String
  , title :: String
  }

instance encodeJsonRequest :: EncodeJson Request where
  encodeJson (Request o) = "url" := o.url ~> jsonEmptyObject

url :: String
url = "http://localhost:8080"

notify :: Request -> forall b. Aff (ajax :: AJAX | b) Unit
notify req = do
  y <- post url (encodeJson req)
  pure y.response

notifyTabId id = launchAff do
  tab <- Promise.toAff $ Tabs.get id
  url <- pure $ fromMaybe "" tab.url
  title <- pure $ fromMaybe "" tab.title
  notify (Request {url, title})
  liftEff $ log $ "notified " <> url

log_onUpdated tabId = notifyTabId tabId
log_onActivated {tabId} = notifyTabId tabId

main = do
  _ <- subscribe Tabs.onUpdated log_onUpdated
  _ <- subscribe Tabs.onActivated log_onActivated
  pure unit
