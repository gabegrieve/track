class ServiceBudget < ApplicationRecord
  belongs_to :project
  has_many :time_entries, dependent: :restrict_with_error
  has_many :invoice_budget_summaries, dependent: :restrict_with_error

  enum :cadence, { project: "project", monthly: "monthly" }, default: :project

  validates :name, presence: true
  validates :budget_minutes, numericality: { only_integer: true, greater_than: 0 }

  scope :active, -> { where(archived: false) }

  def budget_hours
    budget_minutes.to_d / 60
  end

  def budget_hours=(hours)
    self.budget_minutes = (BigDecimal(hours.to_s) * 60).round if hours.present?
  rescue ArgumentError
    self.budget_minutes = nil
  end

  def display_name
    "#{project.name} — #{name}"
  end
end
