require 'eks-cent'

ROUTES = EksCent::Router.new do
  # Main Pages - Dynamic based on Type
  get '/' do |req, res|
    type = FEATURES_CONFIG['type'] || 'landing_page'
    case type
    when 'portfolio'
      projects = Project.where(is_active: true).order(Sequel.desc(:created_at)).all
      res.render 'portfolio', title: "Portfolio - One-For-All", projects: projects
    when 'blog'
      posts = Post.where(is_active: true).order(Sequel.desc(:created_at)).all
      res.render 'blog_home', title: "Blog - One-For-All", posts: posts
    when 'e_commerce'
      ProductsController.new(req, res).index
    else
      res.render 'index', title: "One-For-All Framework"
    end
  end

  # --- E-Commerce Routes ---
  get '/products' do |req, res|
    ProductsController.new(req, res).index
  end

  get '/products/:slug' do |req, res|
    ProductsController.new(req, res).show
  end

  get '/cart' do |req, res|
    CartController.new(req, res).index
  end

  post '/cart/add' do |req, res|
    CartController.new(req, res).add
  end

  post '/cart/update' do |req, res|
    CartController.new(req, res).update
  end

  post '/cart/remove' do |req, res|
    CartController.new(req, res).remove
  end

  post '/cart/clear' do |req, res|
    CartController.new(req, res).clear
  end

  get '/docs' do |req, res|
    res.render 'docs', title: "Documentation - One-For-All"
  end

  # --- CMS Dashboard ---
  if FEATURES_CONFIG['cms']
    get '/dashboard' do |req, res|
      DashboardController.new(req, res).index
    end
    
    post '/dashboard/upload' do |req, res|
      DashboardController.new(req, res).upload
    end

    # Resourceful CMS Routes
    resources :pages, prefix: '/dashboard'
    resources :posts, prefix: '/dashboard'
    resources :projects, prefix: '/dashboard'
    resources :products, prefix: '/dashboard'
  end

  # Auth Routes
  if FEATURES_CONFIG['auth']
    get '/login' do |req, res|
      AuthController.new(req, res).show_login
    end

    post '/login' do |req, res|
      AuthController.new(req, res).login
    end

    post '/logout' do |req, res|
      AuthController.new(req, res).logout
    end
  end

  # API Namespace
  namespace '/api' do
    get '/status' do |req, res|
      ApiController.new(req, res).status
    end
  end
  # --- Dynamic Content ---
  get '/posts/:slug' do |req, res|
    post = Post.find(slug: req.params['slug'], is_active: true)
    if post
      res.render('post', title: post.title, post: post)
    else
      res.status = 404
      res.render('error', layout: false, message: "Article not found.")
    end
  end

  get '/projects/:slug' do |req, res|
    project = Project.find(slug: req.params['slug'], is_active: true)
    if project
      res.render('project', title: project.title, project: project)
    else
      res.status = 404
      res.render('error', layout: false, message: "Project not found.")
    end
  end

  # --- Dynamic Pages (Catch-All) ---
  get '/:slug' do |req, res|
    page = Page.find(slug: req.params['slug'], is_active: true)
    if page
      res.render('page', title: page.title, content: page.content)
    else
      res.status = 404
      res.render('error', layout: false, message: "Page '#{req.params['slug']}' not found.")
    end
  end
end
