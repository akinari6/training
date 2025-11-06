source 'https://rubygems.org'

ruby '3.2.8'

gem 'bcrypt', '~> 3.1'
gem 'bootsnap', '~> 1.18', require: false
gem 'importmap-rails'
gem 'jbuilder'
gem 'pg', '~> 1.5', group: :production
gem 'puma', '~> 6.4'
gem 'rails', '~> 7.1.3'
gem 'redis', '~> 5.0'
gem 'sassc-rails', '~> 2.1'
gem 'sqlite3', '~> 1.7', group: %i[development test]
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'view_component', '~> 3.11'

group :development, :test do
  gem 'capybara'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails', '~> 6.1'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

group :development do
  gem 'listen'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'
end

group :test do
  gem 'simplecov', require: false
end

group :ai do
  gem 'anthropic', '~> 1.13'
  gem 'faraday-retry'
  gem 'httparty'
  gem 'octokit'
end
