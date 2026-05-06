require_relative 'application_controller'

class PostsController < ApplicationController
  def index
    @posts = Post.order(Sequel.desc(:created_at)).all
    render 'cms/posts_index'
  end

  def new
    @post = Post.new
    render 'cms/posts_form'
  end

  def create
    data = params['post']
    data['is_active'] = boolean_param(data['is_active'])
    @post = Post.new(data)
    if @post.save
      log_activity("Created post: #{@post.title}", @post, "Category: #{@post.category}")
      redirect_to '/dashboard/posts'
    else
      render 'cms/posts_form'
    end
  end

  def edit
    @post = Post[params['id']]
    render 'cms/posts_form'
  end

  def update
    @post = Post[params['id']]
    data = params['post']
    data['is_active'] = boolean_param(data['is_active'])
    if @post.update(data)
      log_activity("Updated post: #{@post.title}", @post, "New Data: #{data.reject{|k| k == 'content'}.to_json}")
      redirect_to '/dashboard/posts'
    else
      render 'cms/posts_form'
    end
  end

  def destroy
    @post = Post[params['id']]
    title = @post.title
    delete_from_storage(@post.image_url) if @post.respond_to?(:image_url)
    delete_all_images_from_content(@post.content) if @post.respond_to?(:content)
    @post.destroy
    log_activity("Deleted post: #{title}")
    redirect_to '/dashboard/posts'
  end
end
