# frozen_string_literal: true

require "date"
require "time"
require_relative "utils/state_manager"

# Evolves market state based on merged PR count.
class MarketSimulator
  PHASE_INCREMENT_THRESHOLD = 3

  def initialize(state_manager: Utils::StateManager.new)
    @state_manager = state_manager
  end

  def run
    state = @state_manager.market_state
    state[:merged_prs_count] += 1
    maybe_increment_phase(state)
    state[:last_updated] = Time.now.utc.iso8601
    @state_manager.update_market_state(state)
  end

  private

  def maybe_increment_phase(state)
    return unless state[:merged_prs_count] % PHASE_INCREMENT_THRESHOLD == 0

    state[:phase] += 1
    adjust_requirements(state)
  end

  def adjust_requirements(state)
    phase = state[:phase]
    case phase
    when 1..2
      state[:user_count] = 100 * (2**(phase - 1))
      requirements(state, 500, 20, 60)
    when 3..4
      state[:user_count] = 400 * (phase - 2)
      requirements(state, 400, 15, 70)
    when 5..6
      state[:user_count] = 1600 * (phase - 4)
      requirements(state, 300, 12, 75)
    else
      state[:user_count] *= 2
      requirements(state, [150, 200].sample, 8, 85)
    end
  end

  def requirements(state, response_time, queries, coverage)
    state[:performance_requirements][:max_response_time_ms] = response_time
    state[:performance_requirements][:max_db_queries_per_request] = queries
    state[:performance_requirements][:required_test_coverage_percent] = coverage
  end
end
