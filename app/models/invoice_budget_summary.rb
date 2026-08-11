class InvoiceBudgetSummary < ApplicationRecord
  belongs_to :invoice
  belongs_to :service_budget

  validates :name, :cadence, :budget_minutes, :used_minutes, presence: true
  validates :budget_minutes, :used_minutes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def remaining_minutes
    budget_minutes - used_minutes
  end

  def percentage_used
    return 0 if budget_minutes.zero?

    (used_minutes.to_d / budget_minutes * 100).round(1)
  end

  def period_label
    monthly? && period_start ? period_start.strftime("%B %Y") : "Project total"
  end

  def monthly?
    cadence == "monthly"
  end
end
