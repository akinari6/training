# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :user

  enum :priority, { low: 0, medium: 1, high: 2 }

  scope :completed, -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }

  validates :title, presence: true
end
