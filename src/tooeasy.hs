{-# LANGUAGE OverloadedStrings      #-}

module TooEasy where

import qualified Hakit as H
import qualified Data.List.Split as Spl
import qualified System.Directory as D
import qualified Data.List as L
import qualified Hakit.Spice as Sp
import qualified Data.ByteString.Char8 as C
import qualified Data.Text as T
import Debug.Trace

parseMeta :: String -> H.Document
parseMeta s =
    let byLine = Spl.splitOn "\n" s
        byColon = map (Spl.splitOn ":") byLine
        fil = map (\xs -> [xs!!0, T.unpack . T.strip $ T.pack (xs!!1)]) $ filter (\xs -> length xs == 2) byColon
    in H.interpretDoc $ map (\xs -> (C.pack (xs!!0), Just $ C.pack (xs!!1))) fil

indexify :: String -> IO [(H.Document, Sp.Tag)]
indexify dir = do
    fnames' <- D.getDirectoryContents dir
    let fnames = filter (not . L.isPrefixOf ".") fnames'
    mapM (\fn -> (readFile $ dir ++ "/" ++ fn) >>= \x -> return $ process x fn) $ trace (show fnames) fnames
    where
    process :: String -> String -> (H.Document, Sp.Tag)
    process str fileName =
        let s = Spl.splitOn "---" str
            body' :: [Sp.Tag]
            body' = Sp.parseHtml . T.pack $ L.intercalate "" $ tail s
            body = if length body' > 1
                then Sp.div' [] body'
                else body
            meta = parseMeta (s!!0)
        in if length s < 2
            then error $ "Can't find metadata in file " ++ str
            -- We wrap the body in a div if it is more than one tag.
            else (H.set "fileName" fileName meta, body)
                