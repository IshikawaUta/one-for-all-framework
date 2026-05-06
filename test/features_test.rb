require_relative 'test_helper'

class FeaturesTest < Minitest::Test
  def setup
    # Clear logs and maintenance mode before each test
    ActivityLog.dataset.delete rescue nil
    config_path = File.join(APP_ROOT, 'config', 'features.json')
    config = JSON.parse(File.read(config_path))
    config['maintenance'] = false
    File.write(config_path, JSON.pretty_generate(config))
  end

  def test_maintenance_mode_toggle
    # Turn ON
    system("ruby bin/ofa maintenance on > /dev/null")
    config = JSON.parse(File.read(File.join(APP_ROOT, 'config', 'features.json')))
    assert_equal true, config['maintenance']

    # Turn OFF
    system("ruby bin/ofa maintenance off > /dev/null")
    config = JSON.parse(File.read(File.join(APP_ROOT, 'config', 'features.json')))
    assert_equal false, config['maintenance']
  end

  def test_activity_logging
    # Test logging manually
    ActivityLog.log(1, "Test Action", nil, "Details here")
    log = ActivityLog.order(:created_at).last
    
    assert_equal "Test Action", log.action
    assert_equal "1", log.user_id
    assert_equal "Details here", log.details
  end

  def test_plugin_generator
    plugin_name = "test_plugin_#{Time.now.to_i}"
    plugin_path = File.join(APP_ROOT, 'plugins', plugin_name)
    
    begin
      system("ruby bin/ofa g plugin #{plugin_name} > /dev/null")
      assert Dir.exist?(plugin_path)
      assert File.exist?(File.join(plugin_path, "init.rb"))
    ensure
      FileUtils.rm_rf(plugin_path) if Dir.exist?(plugin_path)
    end
  end

  def test_maintenance_middleware_blocks_access
    # Mock environment
    env = {
      'PATH_INFO' => '/',
      'eks_cent.session' => {}
    }
    
    # 1. Test when maintenance is OFF
    FEATURES_CONFIG['maintenance'] = false
    app = lambda { |e| [200, {}, ['OK']] }
    middleware = MaintenanceMiddleware.new(app)
    status, _, _ = middleware.call(env)
    assert_equal 200, status

    # 2. Test when maintenance is ON (should block)
    config_path = File.join(APP_ROOT, 'config', 'features.json')
    config = JSON.parse(File.read(config_path))
    config['maintenance'] = true
    File.write(config_path, JSON.pretty_generate(config))
    
    status, _, _ = middleware.call(env)
    assert_equal 503, status

    # 3. Test when maintenance is ON but allowed path
    env['PATH_INFO'] = '/login'
    status, _, _ = middleware.call(env)
    assert_equal 200, status

    # 4. Test when maintenance is ON but admin is logged in
    env['PATH_INFO'] = '/'
    env['eks_cent.session'] = { 'user_id' => 1 }
    status, _, _ = middleware.call(env)
    assert_equal 200, status
    
    # Cleanup
    FEATURES_CONFIG['maintenance'] = false
  end
end
