Gem::Specification.new do |spec|
  spec.name          = "one-for-all-framework"
  spec.version       = "5.0.0"
  spec.authors       = ["Ishikawa Uta"]
  spec.email         = ["komikers09@gmail.com"]

  spec.summary       = "Modern & Powerfull web application framework."
  spec.description   = "One-For-All is a high-performance Ruby web framework built for speed and aesthetics. It features a built-in CMS, premium Glassmorphism design, and supports multiple databases including SQLite, MySQL, and MongoDB."
  spec.homepage      = "https://github.com/ishikawauta/one-for-all-framework"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob("{app,bin,config,db,public}/**/*") + ["LICENSE", "README.md", "ofa", "config.ru", "config.eks", "Gemfile", "Procfile", "Dockerfile", ".env.example", ".gitignore"]
  spec.bindir        = "bin"
  spec.executables   = ["ofa"]
  spec.require_paths = ["lib"]

  spec.add_dependency "eks-cent", "~> 4.0.0"
  spec.add_dependency "eksa-server", "~> 1.1", ">= 1.1.1"
  spec.add_dependency "sequel", "~> 5.103"
  spec.add_dependency "sqlite3", "~> 2.9"
  spec.add_dependency "bcrypt", "~> 3.1"
  spec.add_dependency "dotenv", "~> 3.2"
  spec.add_dependency "cloudinary", "~> 2.4"
  spec.add_dependency "mongo", "~> 2.23"
  spec.add_dependency "mysql2", "~> 0.5"
  spec.add_dependency "kramdown", "~> 2.5"
  spec.add_dependency "kramdown-parser-gfm", "~> 1.1"
  spec.add_dependency "jwt", "~> 2.10"
end
