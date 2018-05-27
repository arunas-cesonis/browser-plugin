module Main where

import Prelude (Unit, bind, pure, unit, ($), (>>=), (-), (<$>), show)
import Data.Maybe (fromMaybe)
import Data.DateTime.Instant (unInstant)
import Data.Time.Duration (Milliseconds(..))
import Data.UUID (UUID, genUUID, GENUUID)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Now (NOW, now)
import Control.Monad.Aff (Aff, launchAff, Fiber)
import Control.Monad.Eff.Class (liftEff)
import Control.Promise as Promise
import Data.Argonaut.Encode (class EncodeJson, encodeJson, (:=), (~>))
import Data.Argonaut (jsonEmptyObject)
import Network.HTTP.Affjax (AJAX, post)
import FRP (FRP)
import FRP.Event (subscribe)
import Browser.Tabs as Tabs

newtype Request = Request
  { url :: String
  , title :: String
  , time :: Milliseconds
  , uuid :: UUID
  }

unMilliseconds :: Milliseconds -> Number
unMilliseconds (Milliseconds x) = x

getTime :: forall eff. Eff (now :: NOW | eff) Milliseconds
getTime = unInstant <$> now

instance encodeJsonRequest :: EncodeJson Request where
  encodeJson (Request o) =
    "title" := o.title ~>
    ("time" := unMilliseconds o.time ~>
    ("uuid" := show o.uuid ~>
    ("url" := o.url ~> jsonEmptyObject)))

backend :: String
backend = "http://localhost:8080"

notify :: Request -> forall b. Aff (ajax :: AJAX | b) Unit
notify req = do
  y <- post backend (encodeJson req)
  pure y.response

type NotifyEff eff = (ajax :: AJAX, now :: NOW, uuid :: GENUUID | eff)

notifyTabId
  :: forall eff
  . UUID 
  -> Milliseconds
  -> Tabs.TabID
  -> Eff (NotifyEff eff) (Fiber (NotifyEff eff) Unit)
notifyTabId uuid startTime id = launchAff do
  tab <- Promise.toAff $ Tabs.get id
  time <- liftEff $ (getTime >>= \currentTime-> pure $ currentTime - startTime)
  url <- pure $ fromMaybe "" tab.url
  title <- pure $ fromMaybe "" tab.title
  notify (Request {url, title, time, uuid})

log_onUpdated
  :: forall eff
  . UUID 
  -> Milliseconds
  -> Tabs.TabID
  -> Eff (NotifyEff eff) (Fiber (NotifyEff eff) Unit)
log_onUpdated uuid startTime tabId = notifyTabId uuid startTime tabId

log_onActivated
  :: forall eff
  . UUID 
  -> Milliseconds
  -> Tabs.OnActivatedParameters
  -> Eff (NotifyEff eff) (Fiber (NotifyEff eff) Unit)
log_onActivated uuid startTime {tabId} = notifyTabId uuid startTime tabId

main
  :: forall eff
  .  Eff (NotifyEff (frp :: FRP | eff)) Unit
main = do
  startTime <- getTime
  uuid <- genUUID
  _ <- subscribe Tabs.onUpdated (log_onUpdated uuid startTime)
  _ <- subscribe Tabs.onActivated (log_onActivated uuid startTime)
  pure unit
