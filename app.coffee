fs           = require 'fs'
axis         = require 'axis'
rupture      = require 'rupture'
autoprefixer = require 'autoprefixer-stylus'
js_pipeline  = require 'js-pipeline'
css_pipeline = require 'css-pipeline'
records      = require 'roots-records'
collections  = require 'roots-collections'
excerpt      = require 'html-excerpt'
moment       = require 'moment'
readdirp     = require 'readdirp'
path         = require 'path'

monthNames = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]

module.exports =
  ignores: ['readme.md', '**/layout.*', '**/includes/_*', '.gitignore', 'ship.*conf', '**/index2.*', '**/main.*', '**/post2.*']

  locals:
    postExcerpt: (html, length, ellipsis) ->
      excerpt.text(html, length || 100, ellipsis || '...')
    dateFormat: (date, format) ->
      moment(date).format(format)


  extensions: [
    records(
      characters: { file: "data/characters.json" }
      site: { file: "data/site.json" }
    ),
    collections(folder: 'posts', layout: 'post'),
    js_pipeline(files: 'assets/js/*.coffee'),
    css_pipeline(files: 'assets/css/*.styl')
  ]

  stylus:
    use: [axis(), rupture(), autoprefixer()]
    sourcemap: true

  'coffee-script':
    sourcemap: true

  jade:
    pretty: true

  after:->

    options = {
      url: 'https://www.blog.webriq.com',
      file: '**/*.html'
    }

    result = ""

    stream = readdirp({root:path.join(__dirname), fileFilter: [options.file], directoryFilter: ['!node_modules','!includes','!admin','!slider']})
    stream.on 'data', (entry)->

      url_path = entry.path
      str = url_path.replace(/\\/g, "/")
      file = str.substr(6);

      result += "<url><loc>" + options.url + file + "</loc></url>" + "\n";

      fs.writeFile 'public/sitemap.xml', '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'+result+'</urlset>', (err) ->
        if err then console.log err
        # console.log(result);
