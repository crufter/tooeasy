{-# LANGUAGE OverloadedStrings      #-}

module TooEasy where

import qualified Hakit as H
import qualified Data.List.Split as Spl
import qualified System.Directory as D
import qualified Data.List as L
import qualified Haquery as Haq
import qualified Data.ByteString.Char8 as C
import qualified Data.Text as T
import Debug.Trace

parseMeta :: String -> H.Document
parseMeta s =
    let byLine = Spl.splitOn "\n" s
        byColon = map (Spl.splitOn ":") byLine
        fil = map (\xs -> [xs!!0, T.unpack . T.strip $ T.pack (xs!!1)]) $ filter (\xs -> length xs == 2) byColon
    in H.interpretDoc $ map (\xs -> (C.pack (xs!!0), Just $ C.pack (xs!!1))) fil

parseWrap :: T.Text -> Tag
parseWrap t =
    let p = Haq.parseHtml 
    if length p > 1
        then Haq.div' [] body'
        else body 

indexify :: String -> IO [(H.Document, Haq.Tag)]
indexify dir = do
    fnames' <- D.getDirectoryContents dir
    let fnames = filter (not . L.isPrefixOf ".") fnames'
    mapM (\fn -> (readFile $ dir ++ "/" ++ fn) >>= \x -> return $ process x fn) $ trace (show fnames) fnames
    where
    process :: String -> String -> (H.Document, Haq.Tag)
    process str fileName =
        let s = Spl.splitOn "---" str
            body :: [Haq.Tag]
            body = parseWrap . T.pack $ L.intercalate "" $ tail s
            meta = parseMeta (s!!0)
        in if length s < 2
            then error $ "Can't find metadata in file " ++ str
            -- We wrap the body in a div if it is more than one tag.
            else (H.set "fileName" fileName meta, body)

loadTemplate fileName = parseWrap $ readFile fileName
    