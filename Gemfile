source 'https://rubygems.org'

ruby '2.1.10'

gem 'rails', '4.2.5'

gem 'rails-api'

gem 'pg'

# Use Thin web server, it is required for Faye
gem 'thin'

# Use Faye as websockets provider
gem 'faye-rails'

# Use kaminari for pagination
gem 'kaminari'

# Authentication gem
gem 'devise_token_auth'

group :development, :test do
  # IDE debug gems
  gem 'debase'
  gem 'ruby-debug-ide'

  # Make Rails server console output better.
  gem 'quiet_assets'

  # Test applications with RSpec
  gem 'rspec'
  gem 'rspec-rails'
  gem 'em-rspec'

  # Gem for test data generation
  gem 'factory_girl_rails'
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Gem for Google Chrome extension, that gives a lot of development goodies.
  gem 'meta_request'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', :group => :development

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
