require_relative 'application_controller'

class ProductsController < ApplicationController
  def index
    if req.path.start_with?('/dashboard')
      @products = Product.order(Sequel.desc(:created_at)).all
      render 'cms/products_index'
    else
      @products = Product.where(is_active: true).order(Sequel.desc(:created_at)).all
      render 'products_index', title: "Shop - One-For-All"
    end
  end

  def new
    @product = Product.new
    render 'cms/products_form'
  end

  def create
    data = params['product']
    @product = Product.new(data)
    if @product.save
      redirect_to '/dashboard/products'
    else
      render 'cms/products_form'
    end
  end

  def edit
    @product = Product[params['id']]
    render 'cms/products_form'
  end

  def update
    @product = Product[params['id']]
    if @product.update(params['product'])
      redirect_to '/dashboard/products'
    else
      render 'cms/products_form'
    end
  end

  def destroy
    @product = Product[params['id']]
    @product.destroy
    redirect_to '/dashboard/products'
  end

  def show
    @product = Product.find(slug: params['slug'], is_active: true)
    if @product
      render 'product_show', title: "#{@product.name} - One-For-All"
    else
      @res.status = 404
      render 'error', message: "Product not found."
    end
  end
end
