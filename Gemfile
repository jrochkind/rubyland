source 'https://rubygems.org'

ruby '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
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

gem 'honeybadger', '~> 2.0'

gem 'feedjira', '~> 2.0'
gem 'slim-rails', '~> 3.0'
gem 'addressable', '~> 2.4'
gem 'bootstrap', '>= 4.0.0.alpha5', '< 4.1'
gem 'http', '~> 2.0'
gem "font-awesome-rails", '~> 4.7'
gem 'momentjs-rails', '~> 2.0'
# Need direct to git to get one that allows http 2.x, bah
# https://github.com/sferik/twitter/issues/789
# https://github.com/sferik/twitter/pull/779
gem 'twitter', '~> 5.0', git: "https://github.com/sferik/twitter.git"

# New relic docs suggest we shouldn't really need to add this
# on heroku, but let's try it...
gem 'newrelic_rpm'

# letsencrypt-rails-heroku: Until the new API calls are generally available, you must manually specify my fork
# of the Heroku API gem:
gem 'platform-api', git: 'https://github.com/jalada/platform-api', branch: 'master'
gem 'letsencrypt-rails-heroku', group: 'production'

source 'https://rails-assets.org' do
  gem 'rails-assets-fetch', '~> 1.0'
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
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
