class TimeEntriesController < ApplicationController
  before_action :set_time_entry, only: %i[edit update destroy stop restart]
  before_action :set_service_budgets, only: %i[edit update]

  def start
    project = Project.active.find(start_params[:project_id])
    entry = TimeEntry.new(start_params.merge(project:, started_at: Time.current, hourly_rate_cents: project.hourly_rate_cents))
    entry.save!
    redirect_to root_path, notice: "Timer started."
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => error
    redirect_to root_path, alert: error.message
  end

  def stop
    @time_entry.stop!
    redirect_to root_path, notice: "Timer stopped."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to root_path, alert: error.message
  end

  def manual
    project = Project.active.find(manual_params[:project_id])
    start_time = Time.zone.parse("#{manual_params[:entry_date]} 12:00")
    entry = TimeEntry.new(manual_params.except(:entry_date).merge(project:, started_at: start_time, ended_at: start_time + manual_params[:duration_minutes].to_i.minutes, hourly_rate_cents: project.hourly_rate_cents))
    entry.save!
    redirect_to root_path, notice: "Time entry added."
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => error
    redirect_to root_path, alert: error.message
  end

  def edit
    redirect_to root_path, alert: "Invoiced entries cannot be changed." if @time_entry.locked?
  end

  def update
    if @time_entry.update(edit_params)
      redirect_to root_path, notice: "Time entry updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @time_entry.uninvoiced?
      @time_entry.destroy
      redirect_to root_path, notice: "Time entry deleted."
    else
      redirect_to root_path, alert: "Invoiced entries cannot be deleted."
    end
  end

  def restart
    project = @time_entry.project
    entry = TimeEntry.new(project:, service_budget: @time_entry.service_budget&.archived? ? nil : @time_entry.service_budget, description: @time_entry.description, started_at: Time.current, hourly_rate_cents: project.hourly_rate_cents)
    entry.save!
    redirect_to root_path, notice: "Timer started with the previous details."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to root_path, alert: error.message
  end

  private

  def set_time_entry
    @time_entry = TimeEntry.find(params[:id])
  end

  def set_service_budgets
    @service_budgets = @time_entry.project.service_budgets.active.order(:name)
    @service_budgets = @service_budgets.or(@time_entry.project.service_budgets.where(id: @time_entry.service_budget_id)) if @time_entry.service_budget_id
  end

  def manual_params
    params.require(:time_entry).permit(:description, :project_id, :service_budget_id, :duration_minutes, :entry_date)
  end

  def edit_params
    params.require(:time_entry).permit(:description, :project_id, :service_budget_id, :started_at, :ended_at)
  end

  def start_params
    params.permit(:description, :project_id, :service_budget_id)
  end
end
