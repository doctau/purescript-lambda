module Main
  ( handler
  , main
  ) where

import Prelude (discard, ($))
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE(), log)
import Control.Monad.Eff.Exception (Error, message)
import Node.Express.App (App, get, listenHttp, useOnError, use)
import Node.Express.Handler (Handler)
import Node.Express.Response (sendJson, setStatus)
import Node.Express.Types (EXPRESS)
import Node.HTTP (Server())
import Network.AWS.Lambda.Express


errorHandler :: forall e. Error -> Handler e
errorHandler err = do
  setStatus 400
  sendJson { error: message err }


notFoundHandler :: forall e. Handler e
notFoundHandler = do
  setStatus 404
  sendJson { error: "resource not found" }


indexHandler :: forall e. Handler e
indexHandler = do
  sendJson { status: "ok" }


app :: forall e. App e
app = do
  get "/" indexHandler
  use notFoundHandler
  useOnError errorHandler


handler :: HttpHandler
handler =
  makeHandler app

-- allow this to be run normally, outside Lambda
main :: forall e. Eff ( console :: CONSOLE
                      , express :: EXPRESS
                      | e) Server
main = listenHttp app 8080 \_ ->
  log $ "Listening on 8080 "
