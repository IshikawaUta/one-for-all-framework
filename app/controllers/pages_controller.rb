require_relative 'application_controller'

class PagesController < ApplicationController
  def index
    @pages = Page.all
    render 'cms/pages_index'
  end

  def new
    @page = Page.new
    render 'cms/pages_form'
  end

  def create
    data = params['page']
    data['is_active'] = boolean_param(data['is_active'])
    data['is_nav'] = boolean_param(data['is_nav'])
    @page = Page.new(data)
    if @page.save
      redirect_to '/dashboard/pages'
    else
      render 'cms/pages_form'
    end
  end

  def edit
    @page = Page[params['id']]
    render 'cms/pages_form'
  end

  def update
    @page = Page[params['id']]
    data = params['page']
    data['is_active'] = boolean_param(data['is_active'])
    data['is_nav'] = boolean_param(data['is_nav'])
    if @page.update(data)
      redirect_to '/dashboard/pages'
    else
      render 'cms/pages_form'
    end
  end

  def destroy
    @page = Page[params['id']]
    delete_all_images_from_content(@page.content) if @page.respond_to?(:content)
    @page.destroy
    redirect_to '/dashboard/pages'
  end
end
