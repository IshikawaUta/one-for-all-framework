require 'eksa-mination'
require 'fileutils'
require 'json'
require 'sequel'
require 'bcrypt'

# Backup & Restore Logic outside DSL to ensure execution
CONFIG_FILES = ["config/database.json", "config/features.json"]
CONFIG_FILES.each do |file|
  FileUtils.cp(file, "#{file}.bak") if File.exist?(file)
end

at_exit do
  CONFIG_FILES.each do |file|
    if File.exist?("#{file}.bak")
      FileUtils.mv("#{file}.bak", file)
    end
  end
  FileUtils.rm("db/test.sqlite3") if File.exist?("db/test.sqlite3")
end

describe "Ofa CLI" do
  let(:ofa) { File.join(Dir.pwd, "bin", "ofa") }

  before do
    # Setting lingkungan test yang konsisten
    `./bin/ofa db switch sqlite db/test.sqlite3`
    `./bin/ofa feature enable auth`
    `./bin/ofa type landing_page`
    `./bin/ofa theme dark_glass`
  end

  it "menampilkan bantuan dengan benar" do
    output = `./bin/ofa help`
    expect(output).to include("One-For-All Framework CLI")
  end

  it "dapat meng-generate controller" do
    `./bin/ofa g controller Blog`
    expect(File.exist?("app/controllers/blog_controller.rb")).to be_truthy
    expect(File.read("app/controllers/blog_controller.rb")).to include("class BlogController")
    FileUtils.rm("app/controllers/blog_controller.rb")
  end

  it "dapat mengubah fitur (enable/disable)" do
    config_path = "config/features.json"
    `./bin/ofa feature disable auth`
    new_config = JSON.parse(File.read(config_path))
    expect(new_config["auth"]).to be_falsey
  end

  it "dapat mengganti tipe aplikasi" do
    config_path = "config/features.json"
    `./bin/ofa type portfolio`
    config = JSON.parse(File.read(config_path))
    expect(config["type"]).to eq("portfolio")
  end

  it "dapat mengganti tema aplikasi" do
    config_path = "config/features.json"
    `./bin/ofa theme light_glass`
    config = JSON.parse(File.read(config_path))
    expect(config["theme"]).to eq("light_glass")
  end

  it "dapat mengganti konfigurasi database" do
    config_path = "config/database.json"
    `./bin/ofa db switch postgres production_db`
    config = JSON.parse(File.read(config_path))
    expect(config["adapter"]).to eq("postgres")
    expect(config["database"]).to eq("production_db")
  end

  it "dapat mereset password admin (dan membuat user jika belum ada)" do
    username = "test_admin_#{Time.now.to_i}"
    strong_password = "Secret123" # Memenuhi: 8+ karakter, huruf kapital, angka
    `./bin/ofa reset-password #{username} #{strong_password}`
    
    # Verifikasi langsung ke file DB
    test_db = Sequel.connect("sqlite://db/test.sqlite3")
    user = test_db[:users].first(username: username)
    expect(user).not_to be_nil
    expect(BCrypt::Password.new(user[:password_hash]) == strong_password).to be_truthy
    test_db.disconnect
  end

  it "dapat meng-generate model baru" do
    `./bin/ofa g model TestItem`
    expect(File.exist?("app/models/testitem.rb")).to be_truthy
    expect(File.read("app/models/testitem.rb")).to include("class Testitem < Sequel::Model")
    FileUtils.rm("app/models/testitem.rb")
  end

  it "dapat meng-generate migration baru" do
    `./bin/ofa g migration create_tests`
    migrations = Dir.glob("db/migrations/*_create_tests.rb")
    expect(migrations.any?).to be_truthy
    migrations.each { |f| FileUtils.rm(f) }
  end

  it "dapat meng-generate post blog" do
    `./bin/ofa g post "Testing Post" --author Antigravity --category Tech`
    expect(File.exist?("app/views/posts/testing_post.erb")).to be_truthy
    expect(File.read("app/views/posts/testing_post.erb")).to include("Testing Post")
    FileUtils.rm("app/views/posts/testing_post.erb")
  end

  it "dapat mengganti konfigurasi storage" do
    config_path = "config/features.json"
    `./bin/ofa storage cloudinary`
    config = JSON.parse(File.read(config_path))
    expect(config["storage"]).to eq("cloudinary")
  end

  it "dapat melakukan migrasi data antar database (SQLite)" do
    source_db_path = "db/source_test.sqlite3"
    target_db_path = "db/target_test.sqlite3"
    FileUtils.rm(source_db_path) if File.exist?(source_db_path)
    FileUtils.rm(target_db_path) if File.exist?(target_db_path)
    
    `./bin/ofa db switch sqlite #{source_db_path}`
    username = "migrator_user"
    `./bin/ofa reset-password #{username} Secret123`
    
    `./bin/ofa db migrate-data sqlite #{target_db_path}`
    
    expect(File.exist?(target_db_path)).to be_truthy
    target_db = Sequel.connect("sqlite://#{target_db_path}")
    user = target_db[:users].first(username: username)
    expect(user).not_to be_nil
    target_db.disconnect
    
    FileUtils.rm(source_db_path) if File.exist?(source_db_path)
    FileUtils.rm(target_db_path) if File.exist?(target_db_path)
  end

  it "dapat meng-generate API controller baru" do
    `./bin/ofa g api Shop`
    expect(File.exist?("app/controllers/shop_controller.rb")).to be_truthy
    content = File.read("app/controllers/shop_controller.rb")
    expect(content).to include("class ShopController < ApiController")
    expect(content).to include("render_json")
    FileUtils.rm("app/controllers/shop_controller.rb")
  end

  it "dapat meng-generate dokumentasi Swagger/OpenAPI" do
    `./bin/ofa swagger`
    expect(File.exist?("openapi.json")).to be_truthy
    config = JSON.parse(File.read("openapi.json"))
    expect(config["openapi"]).to eq("3.0.0")
    expect(config["paths"].any?).to be_truthy
    FileUtils.rm("openapi.json")
  end

  it "dapat menampilkan daftar rute" do
    output = `./bin/ofa routes`
    expect(output).to include("Registered Routes")
    expect(output).to include("/api/status")
  end

  it "dapat menjalankan pemeriksaan kesehatan sistem (doctor)" do
    output = `./bin/ofa doctor`
    expect(output).to include("One-For-All Doctor")
    expect(output).to include("Checking .env file")
    expect(output).to include("Checking Database connection")
  end

  it "dapat meng-generate mailer baru" do
    `./bin/ofa g mailer Welcome signup`
    expect(File.exist?("app/mailers/welcome_mailer.rb")).to be_truthy
    expect(File.exist?("app/views/mailers/welcome_mailer/signup.erb")).to be_truthy
    FileUtils.rm("app/mailers/welcome_mailer.rb")
    FileUtils.rm_rf("app/views/mailers/welcome_mailer")
  end

  it "dapat meng-generate task baru" do
    `./bin/ofa g task Cleanup`
    expect(File.exist?("lib/tasks/cleanup.rb")).to be_truthy
    FileUtils.rm("lib/tasks/cleanup.rb")
  end

  it "dapat menjalankan task yang didefinisikan" do
    File.write("lib/tasks/hello.rb", "task :hello do; puts 'Hello Task'; end")
    output = `./bin/ofa task hello`
    expect(output).to include("Running task: hello")
    expect(output).to include("Hello Task")
    FileUtils.rm("lib/tasks/hello.rb")
  end

  it "dapat meng-generate test baru" do
    `./bin/ofa g test unit`
    expect(File.exist?("test/unit_test.rb")).to be_truthy
    FileUtils.rm("test/unit_test.rb")
  end

  it "dapat menjalankan perintah test suite" do
    # Buat dummy test agar tidak error 'No tests found'
    dummy_file = "test/z_dummy_test.rb"
    File.write(dummy_file, "require_relative 'test_helper'\nclass DummyTest < Minitest::Test; def test_pass; assert true; end; end")
    output = `./bin/ofa test #{dummy_file}`
    expect(output).to include("Running tests")
    expect(output).to include("1 runs, 1 assertions")
    FileUtils.rm(dummy_file) if File.exist?(dummy_file)
  end
end
