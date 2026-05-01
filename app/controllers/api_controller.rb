require_relative 'application_controller'
require 'json'

class ApiController < ApplicationController
  def render_json(data, status: 200)
    @res.status = status
    @res.headers['Content-Type'] = 'application/json'
    @res.body << data.to_json
  end

  def status
    render_json({ status: 'ok', version: '2.0.0', type: FEATURES_CONFIG['type'] })
  end

  def halt_error(message, status: 400)
    render_json({ error: message }, status: status)
    throw(:halt)
  end
end
