require_relative 'application_controller'

class ProjectsController < ApplicationController
  def index
    @projects = Project.order(Sequel.desc(:created_at)).all
    render 'cms/projects_index'
  end

  def new
    @project = Project.new
    render 'cms/projects_form'
  end

  def create
    data = params['project']
    data['is_active'] = boolean_param(data['is_active'])
    @project = Project.new(data)
    if @project.save
      redirect_to '/dashboard/projects'
    else
      render 'cms/projects_form'
    end
  end

  def edit
    @project = Project[params['id']]
    render 'cms/projects_form'
  end

  def update
    @project = Project[params['id']]
    data = params['project']
    data['is_active'] = boolean_param(data['is_active'])
    if @project.update(data)
      redirect_to '/dashboard/projects'
    else
      render 'cms/projects_form'
    end
  end

  def destroy
    @project = Project[params['id']]
    delete_from_storage(@project.image_url) if @project.respond_to?(:image_url)
    delete_all_images_from_content(@project.description) if @project.respond_to?(:description)
    @project.destroy
    redirect_to '/dashboard/projects'
  end
end
