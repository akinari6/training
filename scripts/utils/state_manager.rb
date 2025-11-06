# frozen_string_literal: true

require "json"

module Utils
  # Loads and persists state files used by the simulation.
  class StateManager
    attr_reader :state_dir

    def initialize(state_dir: File.expand_path("../../state", __dir__))
      @state_dir = state_dir
    end

    def market_state
      load_json("market_state.json")
    end

    def business_strategy
      load_json("business_strategy.json")
    end

    def development_metrics
      load_json("development_metrics.json")
    end

    def roadmap
      File.exist?(File.join(state_dir, "roadmap.json")) ? load_json("roadmap.json") : {}
    end

    def update_market_state(payload)
      write_json("market_state.json", payload)
    end

    private

    def load_json(filename)
      path = File.join(state_dir, filename)
      JSON.parse(File.read(path), symbolize_names: true)
    end

    def write_json(filename, payload)
      path = File.join(state_dir, filename)
      File.write(path, JSON.pretty_generate(payload))
    end
  end
end
