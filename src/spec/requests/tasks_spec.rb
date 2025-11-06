# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tasks", type: :request do
  let(:user) { create(:user) }

  before do
    post session_path, params: { email: user.email, password: "password123" }
  end

  describe "GET /tasks" do
    it "returns http success" do
      get tasks_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /tasks" do
    it "creates a task" do
      expect do
        post tasks_path, params: { task: attributes_for(:task) }
      end.to change(Task, :count).by(1)
    end
  end
end
