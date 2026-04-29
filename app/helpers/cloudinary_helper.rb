require 'cloudinary'

module CloudinaryHelper
  def self.setup
    Cloudinary.config do |config|
      # In production, use ENV['CLOUDINARY_URL']
      config.secure = true
    end
  end

  def self.upload(file_path)
    Cloudinary::Uploader.upload(file_path)
  end
end
