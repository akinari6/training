# frozen_string_literal: true

user = User.find_or_create_by!(email: "demo@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
end

3.times do |i|
  user.tasks.find_or_create_by!(title: "Sample Task #{i + 1}") do |task|
    task.description = "学習用のサンプルタスク"
    task.due_at = Time.zone.now + (i + 1).days
    task.priority = i % 3
  end
end
