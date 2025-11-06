source "https://rubygems.org"

ruby "3.2.3"

gem "rails", "~> 7.1.3"
gem "pg", "~> 1.5", group: :production
gem "sqlite3", "~> 1.7", group: [:development, :test]
gem "puma", "~> 6.4"
gem "sassc-rails", "~> 2.1"
gem "bootsnap", "~> 1.18", require: false
gem "bcrypt", "~> 3.1"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "redis", "~> 5.0"
gem "view_component", "~> 3.11"

group :development, :test do
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails"
  gem "faker"
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "dotenv-rails"
end

group :development do
  gem "web-console"
  gem "listen"
  gem "spring"
  gem "spring-watcher-listen"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
end

group :test do
  gem "simplecov", require: false
end

group :ai do
  gem "anthropic", "~> 1.13"
  gem "octokit"
  gem "httparty"
end

