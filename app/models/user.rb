require 'bcrypt'

class User < Sequel::Model
  include BCrypt

  # Password strength rules
  MIN_PASSWORD_LENGTH = 8
  PASSWORD_RULES = [
    [/[A-Z]/, "must contain at least one uppercase letter"],
    [/[0-9]/, "must contain at least one number"],
  ]

  # Helper to check if we are in Mongo mode
  def self.mongo?
    defined?(MONGO_CLIENT) && MONGO_CLIENT
  end

  # Override count for Mongo support
  def self.count
    if mongo?
      MONGO_CLIENT[:users].count_documents
    else
      super
    end
  end

  # Override find for Mongo support
  def self.find(params)
    if mongo?
      # Map :id to :_id and handle ObjectId conversion
      if params[:id]
        id_val = params.delete(:id)
        params[:_id] = BSON::ObjectId.from_string(id_val) rescue id_val
      end
      doc = MONGO_CLIENT[:users].find(params).first
      return nil unless doc
      user = User.new
      # Set virtual ID from Mongo _id
      user.values[:id] = doc[:_id].to_s if doc[:_id]
      user.set(
        username: doc[:username],
        password_hash: doc[:password_hash],
        avatar_url: doc[:avatar_url]
      )
      user
    else
      super
    end
  end

  # Override save for Mongo support
  def save
    if self.class.mongo?
      data = {
        username: self.username,
        password_hash: self.password_hash,
        avatar_url: self.avatar_url,
        updated_at: Time.now
      }
      MONGO_CLIENT[:users].update_one({ username: self.username }, { "$set" => data }, { upsert: true })
      self
    else
      super
    end
  end

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    errors = validate_password_strength(new_password)
    raise ArgumentError, "Weak password: #{errors.join(', ')}" if errors.any?

    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def self.authenticate(username, password)
    user = self.find(username: username)
    return user if user && user.password == password
    nil
  end

  private

  # Returns an array of error messages. Empty = valid.
  def validate_password_strength(pwd)
    return ["cannot be empty"] if pwd.nil? || pwd.empty?
    errors = []
    errors << "must be at least #{MIN_PASSWORD_LENGTH} characters" if pwd.length < MIN_PASSWORD_LENGTH
    PASSWORD_RULES.each do |regex, message|
      errors << message unless pwd.match?(regex)
    end
    errors
  end
end
