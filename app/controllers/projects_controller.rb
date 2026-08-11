class ProjectsController < ApplicationController
  before_action :set_project, only: %i[edit update destroy]

  def index
    @projects = Project.order(active: :desc, name: :asc)
  end

  def new
    @project = Project.new(active: true)
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to projects_path, notice: "Project created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @project.update(project_params)
      redirect_to projects_path, notice: "Project updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @project.destroy
      redirect_to projects_path, notice: "Project deleted."
    else
      redirect_to projects_path, alert: @project.errors.full_messages.to_sentence
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :client_name, :client_address, :hourly_rate_cents, :active)
  end
end
