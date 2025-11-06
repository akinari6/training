# frozen_string_literal: true

require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module TaskSim
  class Application < Rails::Application
    config.load_defaults 7.1
    config.time_zone = "Tokyo"
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end
  end
end
