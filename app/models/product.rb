class Product < Sequel::Model
  plugin :timestamps, update_on_create: true
  
  def before_save
    self.slug ||= self.name.downcase.gsub(/[^a-z0-9]/, '-')
    super
  end
end
