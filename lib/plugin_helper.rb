module OFA
  @hooks = {
    on_boot: [],
    after_request: []
  }

  def self.on_boot(&block)
    @hooks[:on_boot] << block
  end

  def self.run_boot_hooks
    @hooks[:on_boot].each(&:call)
  end

  # Helper for plugins to add routes easily
  def self.add_route(method, path, &block)
    # This assumes ROUTES is available globally (defined in config.ru)
    # If not, we might need a different registration mechanism
    if defined?(ROUTES)
      ROUTES.send(method, path, &block)
    else
      # Delay registration if ROUTES not yet defined
      @pending_routes ||= []
      @pending_routes << { method: method, path: path, block: block }
    end
  end

  def self.apply_pending_routes(router)
    return unless @pending_routes
    @pending_routes.each do |r|
      router.send(r[:method], r[:path], &r[:block])
    end
    @pending_routes = []
  end
end
