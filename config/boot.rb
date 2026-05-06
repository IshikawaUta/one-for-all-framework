require 'bundler/setup'
require 'dotenv/load'
Bundler.require(:default)
require 'eks-cent'
require 'json'
require 'kramdown'
begin
  require 'jwt'
rescue LoadError
end

# Basic project structure constants
APP_ROOT ||= File.expand_path('..', __dir__)

# Environment
EKS_ENV = ENV['EKS_ENV'] || 'development'

# Load features config
FEATURES_CONFIG = JSON.parse(File.read(File.join(APP_ROOT, 'config', 'features.json')))

# Load Locales (from framework)
LOCALES = {
  'en' => JSON.parse(File.read(File.join(__dir__, 'locales', 'en.json'))),
  'id' => JSON.parse(File.read(File.join(__dir__, 'locales', 'id.json')))
}

# Monkeypatch EksCent
module EksCent
  def self.secret_key_base
    ENV['SECRET_KEY_BASE'] || 'd8a8b8c8d8e8f8g8h8i8j8k8l8m8n8o8p8q8r8s8t8u8v8w8x8y8z8'
  end

  class Response
    def render(template_name, layout: true, **locals)
      require 'erb'
      template_path = File.join(APP_ROOT, 'app', 'views', "#{template_name}.erb")
      unless File.file?(template_path)
        raise "Template not found: #{template_path}"
      end

      template_content = File.read(template_path)
      context = Object.new
      context.extend(ERB::Util)
      req = @request
      context.instance_variable_set("@req", req)
      context.instance_variable_set("@res", self)
      
      # I18n Helper
      lang = (req && req.params['lang']) || 'en'
      context.define_singleton_method(:t) { |key| LOCALES[lang][key.to_s] || key }
      context.define_singleton_method(:csrf_tag) { "<input type='hidden' name='csrf_token' value='#{req.env['eks_cent.csrf_token']}'>" }
      context.define_singleton_method(:csrf_token) { req ? req.env['eks_cent.csrf_token'] : nil }
      context.define_singleton_method(:markdown) { |text| Kramdown::Document.new(text.to_s, input: 'GFM').to_html }
      context.define_singleton_method(:strip_tags) { |text| text.to_s.gsub(/<[^>]*>/, ' ').gsub(/\s+/, ' ').strip }
      context.define_singleton_method(:preview_text) do |text, length = 160|
        plain = text.to_s.gsub(/<[^>]*>/, ' ') # Hapus HTML tags
        plain = plain.gsub(/!\[.*?\]\(.*?\)/, '') # Hapus Markdown Images
        plain = plain.gsub(/\[(.*?)\]\(.*?\)/, '\1') # Ambil teks dari Markdown Links
        plain = plain.gsub(/\s+/, ' ').strip
        plain.length > length ? "#{plain[0...length]}..." : plain
      end
      
      context.define_singleton_method(:session) { req ? (req.env['eks_cent.session'] || req.env['rack.session'] || {}) : {} }
      context.define_singleton_method(:h) { |s| CGI.escapeHTML(s.to_s) }
      locals.each { |k, v| context.instance_variable_set("@#{k}", v) }
      
      result = ERB.new(template_content).result(context.instance_eval { binding })

      if layout
        layout_name = layout == true ? 'layout' : layout.to_s
        layout_path = File.join(APP_ROOT, 'app', 'views', "#{layout_name}.erb")
        if File.file?(layout_path)
          context.instance_variable_set("@content", result)
          layout_content = File.read(layout_path)
          result = ERB.new(layout_content).result(context.instance_eval { binding })
        end
      end

      @headers['Content-Type'] ||= 'text/html'
      @body << result
    end

    def json(data, status: 200)
      @status = status
      @headers['Content-Type'] = 'application/json'
      @body << data.to_json
    end
  end
end

# Load core framework components
require_relative 'database'

# Autoloading (Framework Core first, then APP_ROOT)
framework_app = File.expand_path('../app', __dir__)
['controllers', 'models', 'middleware', 'helpers', 'mailers'].each do |folder|
  next if folder == 'models' && ENV['SKIP_MODELS']
  loaded = []
  # Load framework core
  Dir.glob(File.join(framework_app, folder, '*.rb')).each do |f| 
    require f
    loaded << File.basename(f)
  end
  
  # Load project specific (if not already loaded by framework)
  if framework_app != APP_ROOT
    Dir.glob(File.join(APP_ROOT, 'app', folder, '*.rb')).each do |f|
      require f unless loaded.include?(File.basename(f))
    end
  end
end

# ─── Routes DSL Extensions ─────────────────────────────────────────────────────
# Extends EksCent::Router with a `resources` helper that auto-generates RESTful
# routes (index, show, new, create, edit, update, destroy) for a given resource.
#
# Usage in config/routes.rb:
#   resources :posts                    # All 7 RESTful routes
#   resources :posts, only: [:index, :show]
module EksCent
  class Router
    # Generate RESTful routes for a resource
    # Maps to a controller: e.g. :posts => PostsController
    def resources(name, only: nil, prefix: nil)
      controller_name = name.to_s.split('_').map(&:capitalize).join + "Controller"
      plural = name.to_s
      path_prefix = prefix ? "#{prefix}/#{plural}" : "/#{plural}"

      all_actions = {
        index:   { method: :get,    path: path_prefix },
        new:     { method: :get,    path: "#{path_prefix}/new" },
        show:    { method: :get,    path: "#{path_prefix}/:id" },
        create:  { method: :post,   path: path_prefix },
        edit:    { method: :get,    path: "#{path_prefix}/:id/edit" },
        update:  { method: :post,   path: "#{path_prefix}/:id/update" },
        destroy: { method: :post,   path: "#{path_prefix}/:id/delete" },
      }

      actions = only ? all_actions.slice(*Array(only)) : all_actions

      actions.each do |action, config|
        send(config[:method], config[:path]) do |req, res|
          controller_class = Object.const_get(controller_name)
          controller_class.new(req, res).public_send(action)
        end
      end
    end
  end
end
# ───────────────────────────────────────────────────────────────────────────────

# Load routes
require_relative 'routes'
