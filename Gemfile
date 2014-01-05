source 'https://rubygems.org'

ruby '1.9.3' # so ruby-prof works (it doesn't yet with 2.0.0)

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.0.0'

gem 'nokogiri'
gem 'pg'
gem 'foreigner'

gem 'randumb' #, :git => 'git://github.com/spilliton/randumb.git'
gem 'json'

# Use SCSS for stylesheets
gem 'sass-rails'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platform => :ruby

gem 'uglifier'
#gem 'twitter-bootstrap-rails'

gem 'font-awesome-rails'
#gem 'simple_form'
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# To use Jbuilder templates for JSON
gem 'jbuilder'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

gem 'guard' # file alteration monitoring
gem 'rb-inotify', :require => false
gem 'rb-fsevent', :require => false
gem 'rb-fchange', :require => false

#gem 'haml-rails'
gem 'parallel' # just for Parallel.processor_count
gem 'geonames_api' #, :path => '../geonames_api' # :github => 'mceachen/geonames_api'
gem 'nominatim'
gem 'findler'
gem 'closure_tree'
gem 'exiftool'
gem 'exiftool_vendored'
gem 'monogamy'
gem 'micro_magick'
gem 'dimensions'
gem 'attr_memoizer'
gem 'memcache-client'
gem 'dalli'
gem 'sidekiq'
gem 'foreman'
gem 'druthers'

group :development do
# TODO: seemed cool:  gem "rails-erd"
#  gem 'debugger'
end

group :test do
  gem 'minitest', '>= 0.9'
  gem 'minitest-rails'
  gem 'minitest-reporters'
  gem 'minitest-great_expectations'
  gem 'miniskirt'
  gem 'database_cleaner'
  gem 'mocha', :require => false

  #gem 'mini_backtrace' # Use Rails.backtrace_cleaner with MiniTest.
  #gem 'capybara'
  #gem 'turn'
end

group :profile do
  gem 'ruby-prof'
end
