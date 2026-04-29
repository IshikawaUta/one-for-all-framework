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
end
