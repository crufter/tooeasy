{-# LANGUAGE OverloadedStrings      #-}

module TooEasy (
    loadPosts,
    loadTemplate
) where

import qualified Hakit as H
import qualified Data.List.Split as Spl
import qualified System.Directory as D
import qualified Data.List as L
import qualified Haquery as Haq
import qualified Data.ByteString.Char8 as C
import qualified Data.Text as T

parseMeta :: String -> H.Document
parseMeta s =
    let byLine = Spl.splitOn "\n" s
        byColon = map (Spl.splitOn ":") byLine
        fil = map (\xs -> [head xs, T.unpack . T.strip . T.pack $ L.intercalate ":" $ tail xs]) $ filter (\xs -> length xs > 1) byColon
    in H.interpretDoc $ map (\xs -> (C.pack (xs!!0), Just $ C.pack (xs!!1))) fil

parseWrap :: T.Text -> Haq.Tag
parseWrap t =
    let p = Haq.parseHtml t
    in if length p > 1
        then Haq.div' [] p
        else p!!0

-- | Loads all posts in a given folder.
loadPosts :: String -> IO [(H.Document, Haq.Tag)]
loadPosts dir = do
    fnames' <- D.getDirectoryContents dir
    let fnames = filter (not . L.isPrefixOf ".") fnames'
    mapM (\fn -> (readFile $ dir ++ "/" ++ fn) >>= \x -> return $ process x fn) fnames
    where
    process :: String -> String -> (H.Document, Haq.Tag)
    process str fileName =
        let s = Spl.splitOn "---" str
            body :: Haq.Tag
            body = parseWrap . T.pack $ L.intercalate "" $ tail s
            meta = parseMeta (s!!0)
        in if length s < 2
            then error $ "Can't find metadata in file " ++ fileName
            -- We wrap the body in a div if it is more than one tag.
            else (H.set "fileName" fileName meta, body)

-- | Loads a single template file.
loadTemplate :: String -> IO Haq.Tag
loadTemplate fileName = readFile fileName >>= \f -> return . parseWrap $ T.pack f
    