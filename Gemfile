source 'https://rubygems.org'

ruby File.read(File.join(__dir__, ".ruby-version")).chomp

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'

# We haven't upgraded to sprockets 4 yet
gem "sprockets", "~> 3.0"

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
#gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
#gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'honeybadger', '~> 4.0'

gem 'feedjira', '~> 3.0'
gem 'slim-rails', '~> 3.0'
gem 'addressable', '~> 2.8'
# backwards breaking changes in bootstrap 4 betas and final, will have to fix
gem 'bootstrap', '~> 4.3'
gem 'http', '~> 4.0'
gem "font-awesome-rails", '~> 4.7'
gem 'momentjs-rails', '~> 2.0'

# Twitter gem unmaintained, and was locking us to old version of http
# that had bugs we had to get rid of. :(
# https://github.com/sferik/twitter/issues/964
# Until we stop using it, use a fork...
gem 'twitter', '~> 6.2', github: "excid3/twitter"

# New relic docs suggest we shouldn't really need to add this
# on heroku, but let's try it...
gem 'newrelic_rpm'

gem "bootsnap", ">= 1.4.4", require: false

source 'https://rails-assets.org' do
  # This is https://github.com/github/fetch polyfill, via bower.
  # While there is a 3.x available, it is written in ES6, so won't actually
  # work in old browsers it's meant to polyfill without a transpile,
  # which seems odd for a polyfill, not sure how to make sure it's being
  # properly transpiled in our build setup.
  # https://github.com/github/fetch/issues/656#issuecomment-420219378
  gem 'rails-assets-fetch', '~> 2.0'
end

require 'rbconfig'
if RbConfig::CONFIG['target_os'] =~ /darwin(1[0-3])/i
  gem 'rb-fsevent', '<= 0.9.4'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
