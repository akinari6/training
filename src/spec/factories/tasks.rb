# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    association :user
    sequence(:title) { |n| "Task #{n}" }
    description { "Sample description" }
    due_at { 2.days.from_now }
    priority { :medium }
    completed { false }
  end
end
