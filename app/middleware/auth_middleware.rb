class AuthMiddleware
  # Session expires after 8 hours of inactivity
  MAX_SESSION_AGE = 60 * 60 * 8

  def initialize(app)
    @app = app
  end

  def call(env)
    # Debug: Check what session keys are available
    # puts "DEBUG KEYS: #{env.keys.select{|k| k.include?('session')}}"
    
    env['eks_cent.session'] ||= env['rack.session'] || {}
    session = env['eks_cent.session']

    # Check for session expiry
    user_id = session['user_id'] || session[:user_id]
    last_active = session['last_active_at'] || session[:last_active_at]

    if user_id && last_active
      age = Time.now.to_i - last_active.to_i
      if age > MAX_SESSION_AGE
        # Clear session if expired
        ['user_id', :user_id, 'username', :username, 'last_active_at', :last_active_at].each { |k| session.delete(k) }
        
        if requires_auth?(env['PATH_INFO'])
          return [302, { 'Location' => '/login?reason=expired' }, []]
        end
      else
        # Update last active time to extend session (sliding expiration)
        session['last_active_at'] = Time.now.to_i
      end
    elsif user_id
      # If logged in but no last_active_at (legacy session), set it now
      session['last_active_at'] = Time.now.to_i
    end

    # If the route requires authentication and user is not logged in
    logged_in = session['user_id'] || session[:user_id] || session['username'] || session[:username]
    if requires_auth?(env['PATH_INFO']) && !logged_in
      return [302, { 'Location' => '/login' }, []]
    end

    @app.call(env)
  end

  private

  def requires_auth?(path)
    path.start_with?('/dashboard') || path.start_with?('/profile')
  end
end
