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
import Data.ByteString.Lazy  ( ByteString )
import Data.Text.Lazy.Encoding
import Data.Semigroup ((<>))
import Graphics.Rendering.Chart.Easy
import Graphics.Rendering.Chart.Backend.Cairo
import Text.HTML.TagSoup
import Contribution
import qualified Data.Text.Lazy as T
import qualified HTMLParser

url :: String
url = "https://github.com/users/CORDEA/contributions"

date :: [String]
date = [
    "2015-01-01",
    "2016-01-01",
    "2017-01-01",
    "2018-01-01",
    "2019-01-01"
    ]

toQuery :: String -> String
toQuery [] = ""
toQuery query = "?to=" ++ query

buildUrl :: String -> String
buildUrl date =
    url ++ toQuery date

sendRequest :: IO ( Response ByteString )
sendRequest =
    newManager tlsManagerSettings >>= \m ->
        httpLbs req m
    where
        Just req = parseUrlThrow $ buildUrl "2018-01-01"

fetched :: Response ByteString -> IO ()
fetched response =
    toFile def "chart.png" $ do
        layout_title .= ""
        plot ( line "contributions" [ [ (d, c) | (Contribution d c) <- grouped ] ] )
    where
        resp = responseBody response
        tags = parseTags $ T.unpack $ decodeUtf8 resp
        parsed = HTMLParser.parse tags
        grouped = perMonth parsed

main :: IO ()
main = fetched =<< sendRequest
