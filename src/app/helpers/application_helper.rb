# frozen_string_literal: true

module ApplicationHelper
  def flash_class(level)
    {
      notice: "alert alert-success",
      alert: "alert alert-danger"
    }.fetch(level.to_sym, "alert alert-info")
  end
end
