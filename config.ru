require_relative 'config/boot'

# Middleware setup
use EksCent::Middleware::ShowExceptions
use EksCent::Middleware::Session, secret: EksCent.secret_key_base
use AuthMiddleware
use CSRFMiddleware
use EksCent::Middleware::Static, root: 'public'
use EksCent::Middleware::Logger

run ROUTES
