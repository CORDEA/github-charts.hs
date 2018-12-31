-- Copyright 2018 Yoshihiro Tanaka
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--   http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Author: Yoshihiro Tanaka <contact@cordea.jp>
-- date  : 2018-12-31

{-# LANGUAGE OverloadedStrings #-}

module Main where

import Network.HTTP.Conduit
import Network.HTTP.Types.Header
import Network.HTTP.Base ( defaultUserAgent )
import Network.URI ( parseURI )
import Data.ByteString.Lazy
import Options.Applicative
import qualified Option
import qualified Data.ByteString.Char8 as B

baseUrl :: String
baseUrl = "https://api.github.com"

setHeaders :: Request -> String -> Request
setHeaders req token =
    req {
        requestHeaders =
            ( hAccept, B.pack "application/vnd.github.raw+json" ) :
            ( hAuthorization, B.pack tokenHeader ) :
            ( hUserAgent, B.pack defaultUserAgent ) :
            requestHeaders req
        }
    where
        tokenHeader = "token " ++ token

buildRequest :: String -> String -> Request
buildRequest token path =
    setHeaders req { method = "GET" } token
    where
        url = baseUrl ++ path
        Just req = parseUrlThrow url

sendRequest :: Request -> IO ( Response ByteString )
sendRequest req =
    newManager tlsManagerSettings >>= \m ->
        httpLbs req m

fetched :: Response ByteString -> IO ()
fetched response =
    return ()

fetchContributions :: Option.CommonOpts -> IO ()
fetchContributions commonOpts =
    fetched =<< sendRequest ( buildRequest token "" )
    where
        ( Option.CommonOpts token ) = commonOpts

parsed :: Option.Args -> IO ()
parsed ( Option.Args args ) = fetchContributions args

main :: IO ()
main = parsed =<< execParser Option.parser
