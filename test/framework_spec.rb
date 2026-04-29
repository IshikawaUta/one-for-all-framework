require 'eksa-mination'
require 'rack'
require 'rack/test'
require_relative '../config/boot'

describe "One-For-All Framework" do
  before do
    extend Rack::Test::Methods
  end

  let(:app) do
    Rack::Builder.new do
      use EksCent::Middleware::Session, secret: EksCent.secret_key_base
      use AuthMiddleware
      use CSRFMiddleware
      use EksCent::Middleware::Logger
      run ROUTES
    end
  end

  it "menampilkan halaman utama dengan benar" do
    get '/'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("One-For-All")
  end

  it "menampilkan halaman login" do
    get '/login'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Welcome Back")
  end

  it "menolak request POST tanpa CSRF token" do
    post '/login', { username: 'admin', password: 'pwd' }
    expect(last_response.status).to eq(403)
    expect(last_response.body).to include("CSRF Token Invalid")
  end

  it "mengarahkan rute terproteksi ke halaman login jika belum autentikasi" do
    get '/dashboard'
    expect(last_response.status).to eq(302)
    expect(last_response.location).to match(/\/login$/)
  end

  it "merespon endpoint API status dengan JSON" do
    get '/api/status'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("ok")
    expect(last_response.headers['Content-Type']).to eq('application/json')
  end
end
