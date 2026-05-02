require_relative 'application_controller'

class CartController < ApplicationController
  def index
    @cart_items = session['cart'] || {}
    # Convert string keys to integers for the query
    @products = Product.where(id: @cart_items.keys.map(&:to_i)).all
    @total = @products.sum { |p| p.price * @cart_items[p.id.to_s].to_i }
    render 'cart_index', title: "Your Cart - One-For-All"
  end

  def add
    product_id = params['product_id']
    qty = params['qty'].to_i
    qty = 1 if qty <= 0
    
    cart = session['cart'] || {}
    cart[product_id] = (cart[product_id].to_i + qty)
    session['cart'] = cart
    
    redirect_to '/cart'
  end

  def remove
    product_id = params['product_id']
    cart = session['cart'] || {}
    cart.delete(product_id)
    session['cart'] = cart
    
    redirect_to '/cart'
  end
  
  def update
    product_id = params['product_id']
    qty = params['qty'].to_i
    
    cart = session['cart'] || {}
    if qty <= 0
      cart.delete(product_id)
    else
      cart[product_id] = qty
    end
    session['cart'] = cart
    
    redirect_to '/cart'
  end

  def clear
    session['cart'] = {}
    redirect_to '/cart'
  end
end
