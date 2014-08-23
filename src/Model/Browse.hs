-- TODO: delete this module, create Model.Tag, etc.
module Model.Browse
    ( getAllTags
    , getTagCounts
    , getTypeCounts
    ) where

import Import

import Model.Resource
import Model.Utils

import qualified Data.Map           as M
import           Database.Esqueleto

-- | Get all tags, sorted alphabetically (ignore case).
getAllTags :: YesodDB App [Entity Tag]
getAllTags = getAllEntities (alphabeticIgnoreCase tagTag)

-- | Get a map of TagId to the number of Resources with that tag.
getTagCounts :: YesodDB App (Map TagId Int)
getTagCounts = fmap (M.fromList . map fromValue) sel
  where
    sel :: YesodDB App [(Value TagId, Value Int)]
    sel = select $
          from $ \rt -> do
          groupBy (rt^.ResourceTagTagId)
          return (rt^.ResourceTagTagId, countRows)

-- | Get a map of ResourceType to the number of Resources with that type.
getTypeCounts :: YesodDB App (Map ResourceType Int)
getTypeCounts = fmap (M.fromList . map fromValue) sel
  where
    sel :: YesodDB App [(Value ResourceType, Value Int)]
    sel = select $
          from $ \r -> do
          groupBy (r^.ResourceType)
          return (r^.ResourceType, countRows)
