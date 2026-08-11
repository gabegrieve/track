class ServiceBudgetsController < ApplicationController
  before_action :set_project
  before_action :set_service_budget, only: :update

  def create
    @service_budget = @project.service_budgets.new(service_budget_params)
    if @service_budget.save
      redirect_to edit_project_path(@project), notice: "Service budget added."
    else
      redirect_to edit_project_path(@project), alert: @service_budget.errors.full_messages.to_sentence
    end
  end

  def update
    if @service_budget.update(service_budget_params)
      redirect_to edit_project_path(@project), notice: "Service budget updated."
    else
      redirect_to edit_project_path(@project), alert: @service_budget.errors.full_messages.to_sentence
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_service_budget
    @service_budget = @project.service_budgets.find(params[:id])
  end

  def service_budget_params
    params.require(:service_budget).permit(:name, :budget_hours, :cadence, :archived)
  end
end
