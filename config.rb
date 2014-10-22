###
# Blog settings
###

Time.zone = 'Tokyo'

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  blog.prefix = "blog"

  blog.permalink = "{year}-{month}-{day}/{title}.html"
  # Matcher for blog source files
  blog.sources = "articles/{year}/{month}/{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  blog.layout = "_layouts/post"
  blog.summary_separator = /(READMORE)/
  blog.summary_length = nil
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  blog.default_extension = ".md"

  blog.tag_template = "blog/tag.html"
  blog.calendar_template = "blog/calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 3
  blog.page_link = "page/{num}"
end

activate :directory_indexes

page "/feed.xml", layout: false

###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", layout: false
#
# With alternative layout
# page "/path/to/file.html", layout: :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
activate :livereload

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :layouts_dir, '_layouts'
set :partials_dir, '_partials'
set :css_dir, 'css'
set :js_dir, 'js'
set :images_dir, 'img'

# markdown
set :markdown_engine, :redcarpet
set(:markdown,
      tables:              true,
      fenced_code_blocks:  true
     )

# slim
set :slim, {:pretty => true, :format => :html5, :streaming => false}

# syntax highlighting
activate :syntax, css_class: 'hl', line_numbers: true

# Disqus
activate :disqus do |d|
  d.shortname = 'tosainu'
end

activate :deploy do |deploy|
  deploy.method = :git
end

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Minify html on build
  activate :minify_html, remove_comments: false

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end
