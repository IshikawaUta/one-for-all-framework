ENV['EKS_ENV'] = 'test'
require 'minitest/autorun'
require 'minitest/pride' # Nice colors

# Load the application environment
require_relative '../config/boot'

class Minitest::Test
  # Add helper methods for tests here
  def setup
    # Run migrations or setup DB for tests
  end
end
