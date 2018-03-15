{-# LANGUAGE OverloadedStrings #-}

module Templates.Post where

import           Hakyll
import           Lucid.Base
import           Lucid.Html5
import qualified Data.Text                 as T

import           Templates.Core
import           Templates.FontAwesome

postTemplate :: FontAwesomeIcons -> LucidTemplate a
postTemplate icons = LucidTemplate $ do
  StringField body  <- lookupMeta "body"
  StringField date  <- lookupMeta "date"
  StringField url   <- lookupMeta "url"
  StringField tags  <- lookupMeta "tags"
  StringField title <- lookupMeta "title"

  main_ [class_ "post", role_ "main"] $
    article_ $ do
      header_ [class_ "post-header"] $
        div_ [class_ "container"] $ do
          h1_ $
            a_  [href_ (T.pack url), title_ (T.pack title)] $ toHtml title

          ul_ [class_ "post-meta"] $ do
            li_                 $ fontawesome' icons "fas" "calendar-alt"
            li_ [class_ "date"] $ toHtml date
            li_                 $ fontawesome' icons "fas" "tags"
            li_ $
              ul_ [class_ "tag-list"] $ toHtmlRaw tags

      div_ [class_ "container"] $
        div_ [class_ "post-contents"] $
          toHtmlRaw body
