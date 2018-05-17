module Main where

import Prelude (Unit, bind, discard, pure, unit, ($), (<>), (>>=), (-), (<$>), show)
import Data.Maybe (fromMaybe)
import Data.DateTime.Instant (Instant, unInstant)
import Data.Time.Duration
import Data.UUID
import Control.Monad.Eff.Now (now)
import Control.Monad.Aff (Aff, launchAff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (log)
import Control.Promise as Promise
import Data.Argonaut.Encode (class EncodeJson, encodeJson, (:=), (~>))
import Data.Argonaut (jsonEmptyObject)
import Network.HTTP.Affjax (AJAX, post)
import Debug.Trace

import FRP.Event (subscribe)
import Browser.Tabs as Tabs

newtype Request = Request
  { url :: String
  , title :: String
  , time :: Milliseconds
  , uuid :: UUID
  }

unMilliseconds (Milliseconds x) = x

getTime = unInstant <$> now

instance encodeJsonRequest :: EncodeJson Request where
  encodeJson (Request o) =
    "title" := o.title ~>
    ("time" := unMilliseconds o.time ~>
    ("uuid" := show o.uuid ~>
    ("url" := o.url ~> jsonEmptyObject)))

url :: String
url = "http://localhost:8080"

notify :: Request -> forall b. Aff (ajax :: AJAX | b) Unit
notify req = do
  y <- post url (encodeJson req)
  pure y.response

notifyTabId startTime id = launchAff do
  tab <- Promise.toAff $ Tabs.get id
  time <- liftEff $ (getTime >>= \currentTime-> pure $ currentTime - startTime)
  url <- pure $ fromMaybe "" tab.url
  title <- pure $ fromMaybe "" tab.title
  uuid <- liftEff $ genUUID
  notify (spy (Request {url, title, time, uuid}))

log_onUpdated startTime tabId = notifyTabId startTime tabId
log_onActivated startTime {tabId} = notifyTabId startTime tabId

main = do
  startTime <- getTime
  _ <- subscribe Tabs.onUpdated (log_onUpdated startTime)
  _ <- subscribe Tabs.onActivated (log_onActivated startTime)
  pure unit
