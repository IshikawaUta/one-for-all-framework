begin
  require 'jwt'
rescue LoadError
end

class JwtMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    auth_header = env['HTTP_AUTHORIZATION']
    if auth_header && auth_header.start_with?('Bearer ')
      token = auth_header.split(' ').last
      begin
        secret = ENV['JWT_SECRET'] || 'one-for-all-secret-key'
        if defined?(JWT)
          decoded_token = JWT.decode(token, secret, true, { algorithm: 'HS256' })
          env['current_user_id'] = decoded_token[0]['user_id']
          env['jwt_payload'] = decoded_token[0]
        end
      rescue JWT::DecodeError
        # If token is invalid, we don't halt here, just don't set current_user_id
      rescue NameError
        # JWT not defined
      end
    end

    @app.call(env)
  end
end
