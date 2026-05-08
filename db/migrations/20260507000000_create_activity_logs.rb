Sequel.migration do
  change do
    create_table?(:activity_logs) do
      primary_key :id
      String :user_id
      String :action, null: false
      String :target_type
      String :target_id
      Text :details
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
