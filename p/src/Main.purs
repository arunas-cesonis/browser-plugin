module Main where

import Prelude
import Data.Maybe
import Data.String
import Control.Monad.Aff
import Control.Monad.Eff.Class
import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Control.Promise as Promise
import Control.Promise (Promise)
import Data.Argonaut.Encode
import Data.Argonaut
import Network.HTTP.Affjax
import Network.HTTP.Affjax.Request
import Network.HTTP.Affjax.Response

import FRP (FRP)
import FRP.Event (subscribe)
import Browser.Tabs as Tabs

newtype Request = Request
  { url :: String
  }

instance encodeJsonRequest :: EncodeJson Request where
  encodeJson (Request o) = "url" := o.url ~> jsonEmptyObject

notify :: Request -> forall b. Aff (ajax :: AJAX | b) Unit
notify req = do
  y <- post "http://localhost:8080" (encodeJson req)
  pure y.response

notifyTabId id = launchAff do
  tab <- Promise.toAff $ Tabs.get id
  url <- pure $ fromMaybe "" tab.url
  notify (Request {url})
  liftEff $ log $ "notified " <> url

log_onUpdated tabId = notifyTabId tabId
log_onActivated {tabId} = notifyTabId tabId

main = do
  _ <- subscribe Tabs.onUpdated log_onUpdated
  _ <- subscribe Tabs.onActivated log_onActivated
  pure unit
