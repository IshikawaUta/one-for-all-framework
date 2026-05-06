Sequel.migration do
  change do
    create_table?(:products) do
      primary_key :id
      String :name, null: false
      String :slug, null: false, unique: true
      String :description, text: true
      Float :price, default: 0.0
      Integer :stock, default: 0
      String :image_url
      String :category
      TrueClass :is_active, default: true
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
