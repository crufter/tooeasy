{-# LANGUAGE OverloadedStrings      #-}

import qualified Haquery as Haq
import qualified TooEasy as Too

main = do
    posts <- Too.indexify "posts"
    templ <- Too.loadTemplate "template.html"
    