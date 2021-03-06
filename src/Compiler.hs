{-# LANGUAGE OverloadedStrings #-}

module Compiler
  ( renderKaTeX
  , renderFontAwesome
  , optimizeSVGCompiler
  , absolutizeUrls
  , prependBaseUrl
  , cleanIndexHtmls
  , modifyExternalLinkAttributes
  ) where

import           Control.Monad
import           Data.Char
import qualified Data.HashMap.Strict    as HM
import           Data.Maybe             (fromMaybe)
import           Hakyll
import           System.FilePath
import qualified Text.HTML.TagSoup      as TS
import qualified Text.HTML.TagSoup.Tree as TST

import           FontAwesome

renderKaTeX :: Item String -> Compiler (Item String)
renderKaTeX =
    withItemBody $ fmap (TST.renderTreeOptions tagSoupOption) . transformTreeM f . TST.parseTree
  where
    f tag@(TST.TagBranch _ as [TST.TagLeaf (TS.TagText e)])
      | hasMathClass as =
          TST.parseTree <$> unixFilter "tools/katex.js" ["displayMode" | hasDisplayClass as] e
      | otherwise = return [tag]
    f tag = return [tag]

    hasDisplayClass = elem "display" . classes
    hasMathClass = elem "math" . classes
    classes = words . fromMaybe "" . lookup "class"

renderFontAwesome :: FontAwesomeIcons -> Item String -> Compiler (Item String)
renderFontAwesome icons = return . fmap
    (TST.renderTreeOptions tagSoupOption . TST.transformTree renderFontAwesome' . TST.parseTree)
  where
    renderFontAwesome' tag@(TST.TagBranch "i" as []) =
      case toFontAwesome $ classes as of
           Just tree -> [tree]
           Nothing   -> [tag]
    renderFontAwesome' tag = [tag]

    toFontAwesome (prefix:('f':'a':'-':name):cs) =
      fmap (`appendClasses` cs) (fontawesome icons prefix name)
    toFontAwesome _ = Nothing

    appendClasses t [] = t
    appendClasses (TST.TagBranch x y z) cs =
      let as1 = HM.fromList y
          as2 = HM.singleton "class" $ unwords cs
          y'  = HM.toList $ HM.unionWith (\v1 v2 -> v1 ++ " " ++ v2) as1 as2
      in  TST.TagBranch x y' z
    appendClasses t _ = t

    classes = words . fromMaybe "" . lookup "class"

optimizeSVGCompiler :: [String] -> Compiler (Item String)
optimizeSVGCompiler opts = getResourceString >>=
  withItemBody (unixFilter "node_modules/svgo/bin/svgo" $ ["-i", "-", "-o", "-"] ++ opts)

absolutizeUrls :: Item String -> Compiler (Item String)
absolutizeUrls item = do
  r <- getRoute =<< getUnderlying
  return $ case r of
                Just r' -> fmap (withUrls (absolutizeUrls' r')) item
                _       -> item
  where
    absolutizeUrls' r u
      | not (isExternal u) && isRelative u = normalise $ "/" </> takeDirectory r </> u
      | otherwise = u

prependBaseUrl :: String -> Item String -> Compiler (Item String)
prependBaseUrl base = return . fmap (withUrls prependBaseUrl')
  where
    prependBaseUrl' u
      | not (isExternal u) && isAbsolute u = base <> u
      | otherwise = u

cleanIndexHtmls :: Item String -> Compiler (Item String)
cleanIndexHtmls = return . fmap (withUrls removeIndexHtml)
  where
    removeIndexHtml path
      | not (isExternal path) && takeFileName path == "index.html" = dropFileName path
      | otherwise = path

modifyExternalLinkAttributes :: Item String -> Compiler (Item String)
modifyExternalLinkAttributes = return . fmap (withTags f)
  where
    f t | isExternalLink t = let (TS.TagOpen "a" as) = t
                             in  (TS.TagOpen "a" $ as <> extraAttributs)
        | otherwise        = t
    isExternalLink = liftM2 (&&) (TS.isTagOpenName "a") (isExternal . TS.fromAttrib "href")
    extraAttributs = [("target", "_blank"), ("rel", "nofollow noopener")]

-- https://github.com/jaspervdj/hakyll/blob/v4.11.0.0/lib/Hakyll/Web/Html.hs#L77-L90
tagSoupOption :: TS.RenderOptions String
tagSoupOption = TS.RenderOptions
    { TS.optRawTag   = (`elem` ["script", "style"]) . map toLower
    , TS.optMinimize = (`elem` minimize) . map toLower
    , TS.optEscape   = TS.escapeHTML
    }
  where
    minimize = ["area", "br", "col", "embed", "hr", "img", "input", "meta", "link" , "param"]

concatMapM :: Monad m=> (a -> m [b]) -> [a] -> m [b]
concatMapM f xs = liftM concat (mapM f xs)

transformTreeM :: Monad m
               => (TST.TagTree str -> m [TST.TagTree str])
               -> [TST.TagTree str]
               -> m [TST.TagTree str]
transformTreeM act = concatMapM f
  where
    f (TST.TagBranch a b inner) = transformTreeM act inner >>= act . TST.TagBranch a b
    f x = act x
