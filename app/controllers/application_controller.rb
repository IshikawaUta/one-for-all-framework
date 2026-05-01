class ApplicationController
  attr_reader :req, :res

  def initialize(req, res)
    @req = req
    @res = res
  end

  def params
    @req.params
  end

  def session
    @req.env['eks_cent.session'] ||= @req.env['rack.session'] || {}
  end

  def render(template, **locals)
    # Pass controller instance variables to the view
    instance_variables.each do |var|
      locals[var.to_s.delete('@').to_sym] ||= instance_variable_get(var)
    end
    @res.render(template, **locals)
  end

  def redirect_to(path)
    @res.status = 302
    @res.headers['Location'] = path
  end

  # Validation Helper
  def validate!(required_params)
    missing = required_params.select { |p| params[p.to_s].nil? || params[p.to_s].empty? }
    unless missing.empty?
      @res.status = 400
      render 'error', layout: false, message: "Missing required parameters: #{missing.join(', ')}"
      throw(:halt)
    end
  end

  # CSRF Helper for views
  def csrf_token
    @req.env['eks_cent.csrf_token']
  end

  def boolean_param(val)
    ['1', 'true', 'on'].include?(val.to_s)
  end

  def delete_from_storage(url)
    return unless url && !url.empty?
    if url.include?('cloudinary.com')
      # Extract public_id from Cloudinary URL
      # Example: https://res.cloudinary.com/demo/image/upload/v12345/sample.jpg -> sample
      public_id = url.split('/').last.split('.').first
      begin
        require 'cloudinary'
        Cloudinary::Uploader.destroy(public_id)
      rescue => e
        puts "⚠ Error deleting from Cloudinary: #{e.message}"
      end
    elsif url.start_with?('/images/uploads/')
      path = File.join(APP_ROOT, 'public', url)
      FileUtils.rm(path) if File.exist?(path) rescue nil
    end
  end

  def delete_all_images_from_content(content)
    return unless content
    # Find all Cloudinary URLs in markdown
    urls = content.scan(/https?:\/\/res\.cloudinary\.com\/[^\/]+\/image\/upload\/[^\s\)]+/)
    urls.each { |url| delete_from_storage(url) }
    
    # Also find local uploads
    local_urls = content.scan(/\/images\/uploads\/[^\s\)]+/)
    local_urls.each { |url| delete_from_storage(url) }
  end
end
