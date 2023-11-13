source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.1.1'

gem 'bundler', '~> 2.3', '>= 2.3.11'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'delayed_job_web', '~> 1.4'
gem 'devise', '~> 4.7'
gem 'faraday', '~> 2.4.0'
gem 'faraday-multipart', '~> 1.0', '>= 1.0.4'
gem 'flipper-active_record', '~> 0.25.2'
gem 'gon', '~> 6.3'
gem 'ideal_postcodes', '~> 2.0'
gem 'jbuilder', '~> 2.7'
gem 'lograge', '~> 0.11.2'
gem 'mail-notify', '~> 1.1.0 '
gem 'nilify_blanks', '~> 1.3'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.6'
gem "rails", "~> 7.0.0"
gem 'rails-i18n', '~> 7.0.5'
gem 'redis', '~> 4.1.3'
gem 'restforce', '~> 6.2.3'
gem 'sass-rails', '< 6' # Pinned to old version due to related issue https://github.com/alphagov/whitehall/issues/4724
gem 'silencer', '~> 2.0'
gem 'turbolinks', '~> 5'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby] # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'uk_postcode', '~> 2.1.5'
gem 'view_component', '~> 2.74.1'
gem 'webpacker', '~> 4.0'
gem 'psych', '< 4'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails', '~> 2.7'
  gem 'factory_bot_rails', '~> 5.1'
  gem 'pry', '~> 0.14.1'
  gem 'rails-controller-testing', '~> 1.0.4'
  gem 'rspec-rails', '~> 4.0.0.beta3' # Pinned to beta version due to https://github.com/rspec/rspec-rails/issues/2086
  gem 'rubocop', '~> 0.88.0'
  gem 'rubocop-rspec', '~> 1.42.0'
  gem 'rubocop-rails', '~> 2.7.1'
end

group :development do
  gem 'listen', '>= 3.0.5'
  gem 'spring'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'apparition', '~> 0.6.0'
  gem 'axe-matchers', '~> 2.6.1'
  gem 'capybara', '>= 2.15'
  gem 'database_cleaner-active_record', '~> 1.8'
  gem 'selenium-webdriver', '~> 3.142.7'
  gem 'webdrivers'
  gem 'webmock', '~> 3.8'
end

group :production, :uat, :staging, :training, :civmiguat, :research do
  gem 'aws-sdk-s3', require: false
  gem 'remote_syslog_logger', '~> 1.0', '>= 1.0.4'
  gem 'delayed_job_active_record', '~> 4.1'
  gem 'sentry-raven', '~> 3.1.2'
end
