tooeasy
=======

Too Easy is an minimal static site generator which is barely more than 30 lines.

#### So what's the catch?

It only supports html as source.

#### How does it work?

It uses (part of) the [Hakit](https://github.com/recurziv/hakit) haskell web toolkit and the
[Haquery](https://github.com/recurziv/haquery) HTML manipulation and template engine.

Too Easy currently contains only two functions: one for loading the posts

```haskell
> import TooEasy
> :t loadPosts
loadPosts :: String -> IO [(Hakit.Document, Haquery.Tag)]
```

And one for loading a template file:

```haskell
> :t loadTemplate
loadTemplate :: String -> IO Haquery.Tag
```

Basically, a post looks like this:

```html
title: I am so clever I must share my wisdom on teh internetz!!!!4!
author: joe
---
<p>
    I rant about sum clever things here...
</p>
```

The first part (above the "---") will get parsed to a Hakit.Document (which is basically a map, see Hakit docs), the part below that will be parsed to a
Haquery.Tag.

A template looks like this:

```html
<html>
    <head>
        <title>Title placeholder</title>
    </head>
    <body>
        <div id="content">Content placeholder</div">
    </body>
</html>
```

Now, since you have a list of (metadata, html content), and a html template, and Haquery, a library which allows you to manipulate HTML,
you can easily see how we can build sites with that: insert the metadata and/or html content into the template, and write that to a file. Repeat until blog is exported.

Too easy, right?

For inspiration see the examples folder or the [source for the recurziv blog](https://github.com/recurziv/recirziv.com-src).