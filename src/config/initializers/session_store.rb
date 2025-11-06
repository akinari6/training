# frozen_string_literal: true

Rails.application.config.session_store :cookie_store, key: "_task_sim_session", secure: Rails.env.production?
