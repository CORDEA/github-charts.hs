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
{-# LANGUAGE DeriveGeneric #-}

module CommitActivity where

import Data.Aeson
import Data.Maybe
import GHC.Generics
import qualified Data.ByteString.Lazy as B

data CommitActivities = CommitActivities [CommitActivity] deriving (Show, Generic)

data CommitActivity = CommitActivity {
    days :: [Int],
    total :: Int,
    week :: Int
    } deriving  (Show, Generic)

instance FromJSON CommitActivities

instance FromJSON CommitActivity

decodeActivities :: B.ByteString -> CommitActivities
decodeActivities json =
    fromJust $ decode json

handleResponse :: B.ByteString -> IO ()
handleResponse json =
    showActivity acts
    where
        ( CommitActivities acts ) = decodeActivities json

showActivity :: [CommitActivity] -> IO ()
showActivity [] =
    return ()
showActivity (act: acts) =
    showActivity acts
