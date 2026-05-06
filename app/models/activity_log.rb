class ActivityLog < Sequel::Model
  # Custom user lookup to support both SQL and Mongo users
  def user
    return @user if defined?(@user)
    @user = User.find(id: self.user_id) rescue nil
  end

  def self.log(user_id, action, target = nil, details = nil)
    log_entry = {
      user_id: user_id.to_s,
      action: action,
      created_at: Time.now
    }

    if target
      log_entry[:target_type] = target.class.name
      log_entry[:target_id] = target.id.to_s rescue nil
    end

    if details
      log_entry[:details] = details.is_a?(Hash) ? details.to_json : details.to_s
    end

    create(log_entry)
  end
end
