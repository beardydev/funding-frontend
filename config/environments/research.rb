require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Set azure as hosts
  config.hosts << ENV.fetch("HOST_URI")

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  config.cache_store = :redis_cache_store, {
    url: "rediss://:#{ENV["REDIS_PASSWORD"]}@#{ENV["REDIS_URL"]}:#{ENV["REDIS_PORT"]}",
    connect_timeout:    60,
    read_timeout:       0.5,
    write_timeout:      0.5,
    reconnect_attempts: 2,
    error_handler: -> (method:, returning:, exception:) {
      # Report errors to Sentry as warnings
      Raven.capture_exception exception, level: 'warning',
                              tags: { method: method, returning: returning }
    }
  }


  # Use a real queuing backend for Active Job (and separate queues per environment).
  config.active_job.queue_adapter = :delayed_job
  # config.active_job.queue_name_prefix = "funding_frontend_ruby_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  RemoteSyslogLogger.send(:include, ActiveSupport::LoggerSilence)
  
  config.logger = ActiveSupport::TaggedLogging.new(
    RemoteSyslogLogger.new(
      ENV["PAPERTRAIL_DESTINATION_URI"], 
      ENV["PAPERTRAIL_DESTINATION_PORT"],
      program: "FFE-#{ENV["RAILS_ENV"]}",
      local_hostname: "#{ENV["HOST_URI"]}"
    )
  )

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
  config.active_storage.service = :research

  # Inserts middleware to perform automatic connection switching.
  # The `database_selector` hash is used to pass options to the DatabaseSelector
  # middleware. The `delay` is used to determine how long to wait after a write
  # to send a subsequent read to the primary.
  #
  # The `database_resolver` class is used by the middleware to determine which
  # database is appropriate to use based on the time delay.
  #
  # The `database_resolver_context` class is used by the middleware to set
  # timestamps for the last write to the primary. The resolver uses the context
  # class timestamps to determine how long to wait before reading from the
  # replica.
  #
  # By default Rails will store a last write timestamp in the session. The
  # DatabaseSelector middleware is designed as such you can define your own
  # strategy for connection switching and pass that into the middleware through
  # these configuration options.
  # config.active_record.database_selector = { delay: 2.seconds }
  # config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  # config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
  # Send emails via notify
  config.action_mailer.default_url_options = { host: "https://#{ENV["HOST_URI"]}" }
  config.action_mailer.delivery_method = :notify
  config.action_mailer.notify_settings = {
      api_key: ENV.fetch("NOTIFY_API_KEY")
  }

  config.x.ideal_postcodes.api_key = ENV["IDEAL_POSTCODES_API_KEY"]
  config.x.salesforce.username = ENV["SALESFORCE_USERNAME"]
  config.x.salesforce.password = ENV["SALESFORCE_PASSWORD"]
  config.x.salesforce.security_token = ENV["SALESFORCE_SECURITY_TOKEN"]
  config.x.salesforce.client_id = ENV["SALESFORCE_CLIENT_ID"]
  config.x.salesforce.client_secret = ENV["SALESFORCE_CLIENT_SECRET"]
  config.x.salesforce.host = "test.salesforce.com"
  
  config.x.payment_encryption_key = ENV["PAYMENT_ENCRYPTION_KEY"]
  config.x.payment_encryption_salt = ENV["PAYMENT_ENCRYPTION_SALT"]
  
  config.x.support_email_address = ENV["SUPPORT_EMAIL_ADDRESS"]
  config.x.reply_email_guid = ENV["REPLY_EMAIL_GUID"]
  config.x.no_reply_email_address = ENV["NO_REPLY_EMAIL_ADDRESS"]
  
  config.lograge.enabled = true
  config.assets.quiet = true
  config.x.consumer.username = ENV["CONSUMER_USERNAME"]
  config.x.consumer.password = ENV["CONSUMER_PASSWORD"]
end
