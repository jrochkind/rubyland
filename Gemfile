source 'https://rubygems.org'

ruby File.read(File.join(__dir__, ".ruby-version")).chomp

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 6.4'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'

# We haven't upgraded to sprockets 4 yet
gem "sprockets", "~> 4.0"

# Use terser as compressor for JavaScript assets
gem 'terser', '~> 1.2'

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

gem 'honeybadger', '~> 5.0'

gem 'feedjira', '~> 3.0'
gem 'slim-rails', '~> 3.0'
gem 'addressable', '~> 2.8'
# backwards breaking changes in bootstrap 4 betas and final, will have to fix
gem 'bootstrap', '~> 4.3'
gem 'http', '~> 5.0'
gem "font-awesome-rails", '~> 4.7'
gem 'momentjs-rails', '~> 2.0'


# We only use for posting tweets
gem 'x', '< 1'

gem "bootsnap", ">= 1.4.4", require: false

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
  gem 'listen', '>= 3.0.5'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
