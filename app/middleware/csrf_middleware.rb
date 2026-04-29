require 'securerandom'

class CSRFMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    env['eks_cent.session'] ||= env['rack.session'] || {}
    session = env['eks_cent.session']
    
    # Generate token if not exists
    session['csrf_token'] ||= SecureRandom.hex(32)
    env['eks_cent.csrf_token'] = session['csrf_token']

    if ['POST', 'PUT', 'DELETE', 'PATCH'].include?(req.request_method)
      token = req.params['csrf_token'] || req.env['HTTP_X_CSRF_TOKEN']
      
      if token != session['csrf_token']
        return [403, { 'Content-Type' => 'text/plain' }, ['Forbidden: CSRF Token Invalid']]
      end
    end

    @app.call(env)
  end
end
