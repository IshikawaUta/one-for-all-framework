require 'sequel'
require 'fileutils'
require 'json'

# Load config from JSON
config_file = File.join(APP_ROOT, 'config', 'database.json')
DB_CONFIG = JSON.parse(File.read(config_file)) rescue { "adapter" => "sqlite", "database" => "db/development.sqlite3" }

# Decide if we should use Environment Variable or JSON Config
# Priority:
# 1. If database.json adapter is 'env', STRICTLY use DATABASE_URL from .env
# 2. Otherwise, STRICTLY use JSON config (this allows local dev to override .env)

use_env = (DB_CONFIG['adapter'] == 'env')
database_url = ENV['DATABASE_URL'] if use_env

if use_env && database_url
  if database_url.start_with?('mongodb')
    require 'mongo'
    begin
      MONGO_CLIENT = Mongo::Client.new(database_url)
      FileUtils.mkdir_p('db')
      DB = Sequel.connect("sqlite://db/data.sqlite3")
      puts "ℹ INFO: MongoDB Atlas connected via ENV." unless ENV['EKS_ENV'] == 'test'
    rescue => e
      puts "⚠ WARNING: Failed to connect to MongoDB Atlas. #{e.message}"
      FileUtils.mkdir_p('db')
      DB = Sequel.connect("sqlite://db/data.sqlite3")
    end
  else
    begin
      DB = Sequel.connect(database_url)
    rescue => e
      puts "⚠ WARNING: Connection failed to DATABASE_URL. Fallback to memory."
      FileUtils.mkdir_p('db')
      DB = Sequel.connect("sqlite://db/data.sqlite3")
    end
  end
else
  # Use JSON config (SQLite, MySQL, etc.)
  case DB_CONFIG['adapter']
  when 'sqlite'
    db_path = DB_CONFIG['database'] || 'db/development.sqlite3'
    FileUtils.mkdir_p('db') unless Dir.exist?('db')
    DB = Sequel.connect("sqlite://#{db_path}")
  when 'mongodb'
    begin
      require 'mongo'
      MONGO_CLIENT = Mongo::Client.new([ DB_CONFIG['host'] || '127.0.0.1:27017' ], database: DB_CONFIG['database'])
      FileUtils.mkdir_p('db')
      DB = Sequel.connect("sqlite://db/data.sqlite3")
    rescue => e
      FileUtils.mkdir_p('db')
      DB = Sequel.connect("sqlite://db/data.sqlite3")
    end
  else
    begin
      # For MySQL, MariaDB, Postgres
      DB = Sequel.connect("#{DB_CONFIG['adapter']}://#{DB_CONFIG['user']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}/#{DB_CONFIG['database']}")
    rescue => e
      FileUtils.mkdir_p('db')
      DB = Sequel.connect("sqlite://db/data.sqlite3")
    end
  end
end

if DB
  DB.extension :pagination
  unless DB.table_exists?(:users)
    DB.create_table :users do
      primary_key :id
      String :username, unique: true, null: false
      String :password_hash, null: false
      String :avatar_url
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  unless DB.table_exists?(:pages)
    DB.create_table :pages do
      primary_key :id
      String :title, null: false
      String :slug, unique: true, null: false
      String :content, text: true
      TrueClass :is_active, default: true
      TrueClass :is_nav, default: true
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  unless DB.table_exists?(:posts)
    DB.create_table :posts do
      primary_key :id
      String :title, null: false
      String :slug, unique: true, null: false
      String :content, text: true
      String :image_url
      String :category
      TrueClass :is_active, default: true
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  unless DB.table_exists?(:projects)
    DB.create_table :projects do
      primary_key :id
      String :title, null: false
      String :slug, unique: true, null: false
      String :description, text: true
      String :link
      String :image_url
      TrueClass :is_active, default: true
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  unless DB.table_exists?(:products)
    DB.create_table :products do
      primary_key :id
      String :name, null: false
      String :slug, null: false, unique: true
      String :description, text: true
      Float :price, default: 0.0
      Integer :stock, default: 0
      String :image_url
      String :category
      TrueClass :is_active, default: true
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  unless DB.table_exists?(:activity_logs)
    DB.create_table :activity_logs do
      primary_key :id
      String :user_id
      String :action, null: false
      String :target_type
      String :target_id
      Text :details
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  # Quick Migration for existing tables
  if DB.table_exists?(:pages)
    DB.alter_table(:pages) { add_column :is_active, TrueClass, default: true unless DB[:pages].columns.include?(:is_active) }
    DB.alter_table(:pages) { add_column :is_nav, TrueClass, default: true unless DB[:pages].columns.include?(:is_nav) }
  end
  if DB.table_exists?(:posts)
    DB.alter_table(:posts) { add_column :is_active, TrueClass, default: true unless DB[:posts].columns.include?(:is_active) }
  end
  if DB.table_exists?(:projects)
    DB.alter_table(:projects) { add_column :is_active, TrueClass, default: true unless DB[:projects].columns.include?(:is_active) }
    DB.alter_table(:projects) { add_column :slug, String, unique: true unless DB[:projects].columns.include?(:slug) }
  end
  # Seed default content if empty
  if DB[:pages].count == 0
    DB[:pages].insert(title: 'About Me', slug: 'about', content: '<h1>About Me</h1><p>Welcome to my website.</p>')
    DB[:pages].insert(title: 'Contact', slug: 'contact', content: '<h1>Contact Me</h1><p>Email: admin@example.com</p>')
  end

  if DB[:posts].count == 0
    DB[:posts].insert(title: 'Hello World', slug: 'hello-world', content: 'This is my first post.', category: 'General')
  end

  if DB[:projects].count == 0
    DB[:projects].insert(title: 'My First Project', slug: 'my-first-project', description: 'Description of my first project.', link: 'https://github.com')
  end
end
