source 'https://rubygems.org'

ruby '2.1.2'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.8'
#ruby-gemset=rails418

# Connect to MS SQL Database
gem 'tiny_tds' 
gem 'activerecord-sqlserver-adapter'

# Set environment variables within application.yml
gem "figaro" 

# Use haml
gem 'haml'

# haml generators for Rails 4. Also enables haml as the templating engine
#gem "haml-rails", "~> 0.9"

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Twitter Bootstrap styling
gem 'twbs_sass_rails'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
gem 'unicorn'

# jQuery plugin for drop-in fix binded events problem caused by Turbolinks
gem 'jquery-turbolinks'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Multi-parameter searching
gem "polyamorous"#, :github => "activerecord-hackery/polyamorous"
gem "ransack"#, github: "activerecord-hackery/ransack", branch: "rails-4.1"

# Flexible authentication solution for Rails with Warden. http://blog.plataformatec.com.br/tag/devise/
gem 'devise'

# Pagination
gem 'kaminari-bootstrap'

# Bootstrap Typeahead gem for Rails 3 assets pipeline.
gem 'bootstrap-typeahead-rails'

# File uploads for Rails, Sinatra and other Ruby web frameworks - https://github.com/carrierwaveuploader/carrierwave
gem 'carrierwave'

# Image processing
gem 'rmagick', :require => false

# Background jobs
gem 'sidekiq'

# Authorization
gem 'cancancan'

# Needed for sidekiq  web interface 
gem 'sinatra', :require => nil

# Administration interface
gem 'activeadmin', github: 'gregbell/active_admin'

# Provide a clear syntax for writing and deploying cron jobs.
gem 'whenever', :require => false

# Quickbooks Online REST API Version 3
gem 'quickbooks-ruby'#, github: 'ruckus/quickbooks-ruby'

# OpenID strategy for OmniAuth (single sign on)
gem 'omniauth-openid'

# PDF generator (from HTML) plugin
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# SOAP calls (TUD devices web service calls)
gem 'savon'

# Exception notifications
gem 'exception_notification', '4.1.1'

# See the speed of a request on the page
# gem 'rack-mini-profiler'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

