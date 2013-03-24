{-# LANGUAGE OverloadedStrings      #-}

import qualified Haquery as Haq
import qualified Hakit as H
import qualified TooEasy as Too
import qualified Data.Text as T
import qualified System.Directory as D

siteF = "_site"

main = do
    posts <- Too.loadPosts "posts"
    templ <- Too.loadTemplate "template.html"
    sitesEx <- D.doesDirectoryExist siteF
    if sitesEx
        then return ()
        else D.createDirectory siteF
    mapM_ (processPost templ) posts
    where
    processPost :: Haq.Tag -> (H.Document, Haq.Tag) -> IO ()
    processPost templ post = do
        let fn = T.unpack . H.getString "fileName" $ fst post
            fileName = siteF ++ "/" ++ fn
            body = snd post
            postTitle = T.unpack . H.getString "title" $ fst post
            result = 
                Haq.alter ".content" (\_ -> body) $
                Haq.alter "title" (\_ -> Haq.text . T.pack $ "example site - " ++ postTitle) templ
        putStr $ "Writing file " ++ fileName ++ "\n"
        writeFile fileName . T.unpack $ Haq.render result