class TimeEntry < ApplicationRecord
  belongs_to :project
  belongs_to :service_budget, optional: true
  has_one :invoice_line, dependent: :restrict_with_error

  enum :billing_status, { uninvoiced: "uninvoiced", pending: "pending", paid: "paid" }, default: :uninvoiced

  before_validation :calculate_duration_from_timestamps

  validates :description, presence: true
  validates :started_at, presence: true
  validates :hourly_rate_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :duration_minutes, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :only_one_running_timer, if: :running?
  validate :end_follows_start
  validate :service_budget_matches_project
  validate :locked_entries_cannot_change, on: :update

  scope :completed, -> { where.not(ended_at: nil) }
  scope :newest_first, -> { order(started_at: :desc, created_at: :desc) }

  def running?
    ended_at.nil?
  end

  def locked?
    !uninvoiced?
  end

  def display_duration_minutes
    running? ? ((Time.current - started_at) / 60).ceil : duration_minutes
  end

  def stop!
    now = Time.current
    update!(ended_at: now, duration_minutes: [(now - started_at).fdiv(60).ceil, 1].max)
  end

  private

  def only_one_running_timer
    return unless TimeEntry.where(ended_at: nil).where.not(id: id).exists?

    errors.add(:base, "Only one timer can run at a time")
  end

  def locked_entries_cannot_change
    return unless locked? && (will_save_change_to_description? || will_save_change_to_project_id? || will_save_change_to_service_budget_id? || will_save_change_to_duration_minutes? || will_save_change_to_started_at? || will_save_change_to_ended_at?)

    errors.add(:base, "Invoiced entries are locked")
  end

  def end_follows_start
    return if ended_at.blank? || started_at.blank? || ended_at > started_at

    errors.add(:ended_at, "must be after the start time")
  end

  def calculate_duration_from_timestamps
    return if started_at.blank? || ended_at.blank? || ended_at < started_at

    self.duration_minutes = [(ended_at - started_at).fdiv(60).ceil, 1].max
  end

  def service_budget_matches_project
    return if service_budget.blank? || service_budget.project_id == project_id

    errors.add(:service_budget, "must belong to the selected project")
  end
end
