require_relative 'application_controller'
require 'cloudinary'

class DashboardController < ApplicationController
  def index
    @type = FEATURES_CONFIG['type']
    @stats = {
      pages: Page.count,
      posts: Post.count,
      projects: Project.count,
      products: defined?(Product) ? Product.count : 0,
      users: User.count
    }
    render 'dashboard'
  end

  # Image Upload Action
  def upload
    file = params['file']
    if file && file[:tempfile]
      if FEATURES_CONFIG['storage'] == 'cloudinary'
        begin
          upload = Cloudinary::Uploader.upload(file[:tempfile].path)
          url = upload['secure_url']
          @res.body << { url: url }.to_json
        rescue => e
          @res.status = 500
          @res.body << { error: e.message }.to_json
        end
      else
        filename = "#{Time.now.to_i}_#{file[:filename]}"
        target = File.join(APP_ROOT, 'public/images/uploads', filename)
        FileUtils.cp(file[:tempfile].path, target)
        @res.body << { url: "/images/uploads/#{filename}" }.to_json
      end
    else
      @res.status = 400
      @res.body << { error: "No file uploaded" }.to_json
    end
    @res.headers['Content-Type'] = 'application/json'
    throw(:halt)
  end
end
