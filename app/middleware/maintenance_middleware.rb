class MaintenanceMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # Reload config to ensure instant mode change without server restart
    config = JSON.parse(File.read(File.join(APP_ROOT, 'config', 'features.json'))) rescue (defined?(FEATURES_CONFIG) ? FEATURES_CONFIG : {})
    
    if config['maintenance']
      path = env['PATH_INFO']
      
      # Allow access to login, static assets, and CMS dashboard (if admin)
      # This allows admins to turn off maintenance mode via the dashboard
      allowed_paths = ['/login', '/logout', '/images', '/css', '/js', '/favicon.ico']
      is_allowed = allowed_paths.any? { |p| path.start_with?(p) }
      
      # Also allow if already logged in (admin access)
      session = env['eks_cent.session'] || env['rack.session'] || {}
      is_admin = session['user_id'] || session[:user_id]
      
      if !is_allowed && !is_admin
        # Render maintenance page
        res = EksCent::Response.new
        res.render('maintenance', layout: false)
        return [503, res.headers, res.body]
      end
    end

    @app.call(env)
  end
end
