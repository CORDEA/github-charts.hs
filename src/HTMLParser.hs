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
-- date  : 2019-01-01

module HTMLParser where

import Text.HTML.TagSoup
import Data.List.Split
import Data.Time.Calendar
import Data.Time.LocalTime
import Contribution

toDate :: [Int] -> LocalTime
toDate dates =
    LocalTime ( fromGregorian ( fromIntegral year ) month day ) midnight
    where
        year = dates !! 0
        month = dates !! 1
        day = 1

toContribution :: Tag String -> Contribution
toContribution tag = Contribution {
    date = toDate dates,
    commits = ( read $ fromAttrib "data-count" tag )
    }
    where
        dates = map ( read ) $ splitOn "-" ( fromAttrib "data-date" tag )

parse :: [Tag String] -> [Contribution]
parse tags =
    map (extract . takeWhile (~/= "</>")) . sections (~== "<rect>") $ tags
    where
        extract :: [Tag String] -> Contribution
        extract tags = toContribution $ tags !! 0
