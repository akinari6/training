# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  describe "POST /session" do
    it "logs user in with valid credentials" do
      post session_path, params: { email: user.email, password: "password123" }
      expect(response).to redirect_to(tasks_path)
      follow_redirect!
      expect(response.body).to include("タスク一覧")
    end
  end
end
