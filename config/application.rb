require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Messenger
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.to_prepare do
      DeviseController.respond_to :html, :json
    end

    # Add /lib directory to autoload paths
    config.autoload_paths << Rails.root.join('lib')

    # and nested models directories
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '*/')]

    config.generators do |g|
      # Disable fixtures. Use factory girl instead
      g.fixture_replacement :factory_girl
      g.factory_girl suffix: 'factory'
    end

    # Faye requires to disable Rack::Lock
    config.middleware.delete Rack::Lock
    config.middleware.use FayeRails::Middleware, mount: '/faye', :timeout => 25 do
      # Authenticate clients on each websocket subscription
      map '/**' => Faye::AuthenticationController
      map '/messages/*' => Faye::MessagesController
      map :default => :block
    end
  end
end
