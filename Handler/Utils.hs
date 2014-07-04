module Handler.Utils
    ( alphabeticIgnoreCase
    , denyPermissionIfDifferentUser
    , denyPermissionIfDoesntHaveAuthorityOver
    , denyPermissionIfNotAdmin
    ) where

import Import

import           Model.User (isAdministrator, userHasAuthorityOver)

import qualified Data.Text  as T

-- TODO: Find a better module for this function.
-- Requires that
alphabeticIgnoreCase :: (val -> Text) -> Entity val -> Entity val -> Ordering
alphabeticIgnoreCase textFunc (Entity _ val1) (Entity _ val2) =
    T.toLower (textFunc val1) `compare` T.toLower (textFunc val2)

denyPermissionIfDifferentUser :: UserId -> Handler ()
denyPermissionIfDifferentUser requestedUser = maybeAuthId >>= \case
    Nothing -> deny
    Just thisUser ->
        runDB (get requestedUser) >>= \case
            Nothing -> notFound
            Just _  -> when (requestedUser /= thisUser)
                           deny

denyPermissionIfDoesntHaveAuthorityOver :: UserId -> Handler ()
denyPermissionIfDoesntHaveAuthorityOver nerd = maybeAuthId >>= \case
    Nothing -> deny
    Just bully ->
        runDB (get nerd) >>= \case
            Nothing -> notFound
            Just _  -> do
                ok <- runDB $ userHasAuthorityOver bully nerd
                when (not ok)
                    deny

denyPermissionIfNotAdmin :: Handler ()
denyPermissionIfNotAdmin = maybeAuthId >>= \case
    Nothing -> deny
    Just uid -> runDB (isAdministrator uid) >>= \b -> when b deny

deny :: Handler ()
deny = permissionDenied "You don't have permission to view this page."
