class Post < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:title, :slug]
    validates_unique :slug
  end
end
