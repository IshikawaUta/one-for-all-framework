require_relative 'application_controller'

class AuthController < ApplicationController
  def show_login
    if session['user_id']
      redirect_to '/dashboard'
      return
    end
    reason = req.params['reason']
    error = reason == 'expired' ? 'Your session has expired. Please log in again.' : nil
    render 'login', title: 'Login - One-For-All', error: error
  end

  def login
    username = req.params['username']
    password = req.params['password']
    
    user = User.authenticate(username, password)
    if user
      # Set session keys
      session['user_id'] = user.id
      session['username'] = user.username
      session['last_active_at'] = Time.now.to_i
      
      redirect_to '/dashboard'
    else
      render 'login', title: 'Login - One-For-All', error: 'Invalid credentials'
    end
  end

  def logout
    ['user_id', :user_id, 'username', :username, 'last_active_at', :last_active_at].each { |k| session.delete(k) }
    redirect_to '/login'
  end
end
