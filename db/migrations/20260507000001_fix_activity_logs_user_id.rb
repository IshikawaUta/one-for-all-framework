Sequel.migration do
  change do
    alter_table(:activity_logs) do
      set_column_type :user_id, String
    end
  end
end
