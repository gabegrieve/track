class DashboardController < ApplicationController
  def index
    @projects = Project.active.order(:name)
    @running_entry = TimeEntry.find_by(ended_at: nil)
    @manual_entry = TimeEntry.new(started_at: Time.zone.now)
    @time_entries = filter_entries
  end

  private

  def filter_entries
    entries = TimeEntry.includes(:project).newest_first
    case params[:range]
    when "week"
      entries.where(started_at: Time.current.beginning_of_week..Time.current.end_of_week)
    when "month"
      entries.where(started_at: Time.current.beginning_of_month..Time.current.end_of_month)
    when "year"
      entries.where(started_at: Time.current.beginning_of_year..Time.current.end_of_year)
    when "custom"
      start_date = Date.parse(params[:start_date]) rescue nil
      end_date = Date.parse(params[:end_date]) rescue nil
      entries = entries.where("started_at >= ?", start_date.beginning_of_day) if start_date
      entries = entries.where("started_at <= ?", end_date.end_of_day) if end_date
      entries
    else
      entries.where(started_at: Time.current.beginning_of_week..Time.current.end_of_week)
    end
  end
end
