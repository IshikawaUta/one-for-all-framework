class Project < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:title]
  end
end
