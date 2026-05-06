<p align="center">
  <img src="public/images/logo.png" width="500" height="500" alt="OFA Framework Logo">
</p>

# ⚡ One-For-All (OFA) Framework v4.5.0

[![Ruby Version](https://img.shields.io/badge/ruby-%3E%3D%203.0.0-red.svg)](https://www.ruby-lang.org/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Framework](https://img.shields.io/badge/MVC-Lightweight-orange.svg)]()

**One-For-All (OFA)** is a premium, ultra-fast Ruby MVC framework designed for developers who value both high performance and modern aesthetics. Built on the powerful **Eks-Cent** engine and optimized with **Eksa Server**, OFA v3.0 now supports **Full E-Commerce integration** alongside its stunning "Glassmorphism" UI.

---

## ✨ Why One-For-All?

-   **💎 Premium Aesthetics**: Beautiful Glassmorphism design system included by default with smooth dark/light mode transitions.
-   **🚀 Blazing Fast**: Built on a modular Nio4r-powered engine for minimal overhead and instant boot times.
-   **📂 Multi-Database**: Seamlessly switch and migrate data between SQLite, MySQL, MariaDB, and MongoDB Atlas.
-   **🛠️ Developer First**: A robust CLI (`ofa`) that handles everything from scaffolding to deployment.
-   **🔐 Enterprise Ready**: Built-in CSRF protection, secure session management, and input validation.
-   **🌐 Global Support**: Multi-language (I18n) support and SEO optimization ready.
-   **🖋️ Rich Text Editor**: Integrated Trix Editor for seamless post and page creation with image upload support.
-   **📡 Modern API**: Built-in JWT support and automated Swagger/OpenAPI documentation.
-   **🚧 Maintenance Mode**: Instantly toggle "Under Construction" mode via CLI.
-   **🔍 Activity Logs**: Full audit trail in CMS to monitor user actions and security.
-   **🔌 Plugin System**: Modular architecture to extend the framework with custom add-ons.

---

## 🚀 Getting Started

### 1. Prerequisites
Ensure you have Ruby 3.0+ and Bundler installed on your system.

### 2. Installation
Clone the repository and install dependencies:
```bash
git clone https://github.com/ishikawauta/one-for-all-framework.git
cd one-for-all-framework
bundle install
```

### 3. Quick Initialization
Initialize your project environment and database:
```bash
./ofa init
```
*The interactive wizard will help you configure your database and cloud storage (Cloudinary).*

### 4. Run the Engine
Launch your development server:
```bash
./ofa run
```
Your app is now live at `http://localhost:3000` ⚡

---

## 🛠️ CLI Deep Dive & Expected Outputs

The `ofa` CLI is designed to be interactive and informative. Below is a detailed breakdown of all available commands and the visual feedback they provide.

### 📦 Project & Environment
#### `ofa init [TYPE]`
Initialize your workspace. Triggers an interactive wizard for Database and Storage setup.
*   **Output Example:**
    ```text
    🛠️ Project Configuration
    💾 Choose Database [1. SQLite, 2. MongoDB Atlas]: 2
    🔗 Enter MongoDB Connection String: mongodb+srv://...
    🖼️ Choose Image Storage [1. Local, 2. Cloudinary]: 1
    ✅ Connection string saved to .env
    ✅ Project structure initialized.
    ```

#### `ofa run`
Boots the high-performance Eksa Server engine.
*   **Output Example:**
    ```text
    Starting One-For-All server...
    [INFO] Mendengarkan di TCP: 0.0.0.0:3000
    [EksCent] 2026-05-03 14:40:52 | GET / | Status: 200
    ```

### 🏗️ Generators (Scaffolding)
#### `ofa g controller NAME`
*   **Output:** `✅ Created app/controllers/blog_controller.rb`
#### `ofa g api NAME`
*   **Output:** `✅ Created app/controllers/shop_controller.rb`
#### `ofa g model NAME`
*   **Output:** `✅ Created app/models/product.rb`
#### `ofa g post TITLE [args]`
Creates a SEO-optimized blog post with metadata.
*   **Example:** `./ofa g post "Hello World" --author Antigravity`
*   **Output:** `✅ Created app/views/posts/hello_world.erb`

### 📡 API & Documentation
#### `ofa swagger`
Generates a standards-compliant `openapi.json` file.
*   **Output:** `✅ Documentation saved to: openapi.json`

### 📂 Database Management
#### `ofa db switch TYPE [URL]`
Switches your database adapter on the fly.
*   **Output:** `Switched to mongodb mode.`

#### `ofa db migrate-data TYPE [URL]`
**The most powerful tool.** Moves all data from your current DB to a new one (SQL or MongoDB Atlas).
*   **Output Example:**
    ```text
    📦 Starting data migration: sqlite -> mongodb...
      Migrating users... 12 rows.
      Migrating posts... 45 rows.
    ✅ Migration successful!
    ```

#### `ofa db migrate` (or `ofa migrate`)
Runs pending database migrations in `db/migrations/`.
*   **Output:** `✅ Migrations completed.`

### 🎨 Customization & Security
#### `ofa theme NAME`
Changes the entire UI skin (Modern Glass, Retro, Cyber).
*   **Output:** `✅ Theme set to: retro_terminal`

#### `ofa storage NAME`
Switches between local disk and Cloudinary cloud storage.
*   **Output:** `✅ Storage set to: cloudinary`

#### `ofa reset-password USR PWD`
Securely manages admin credentials.
*   **Output:** `✅ Password for 'admin' updated successfully.`

#### `ofa maintenance [on|off]`
Instantly toggles a premium "Under Construction" page for visitors while allowing admin access.
*   **Output:** `✅ Maintenance mode has been turned on.`

---

### 📁 Project Lifecycle
| Command | Description |
| :--- | :--- |
| `ofa new NAME [TYPE]` | **Create a new project.** Generates a new directory, initializes the framework structure, and automatically runs `bundle install`. |
| `ofa init [TYPE]` | **Initialize in current folder.** Ideal if you've already created a folder or cloned a repository. It triggers an **Interactive Wizard** to configure your Database (SQLite/MongoDB) and Image Storage (Local/Cloudinary). |
| `ofa run` | **Start Development Server.** Boots the high-performance Eksa Server. Your app will be accessible at `http://localhost:3000`. |
| `ofa console` | **Interactive REPL.** Starts a Ruby console pre-loaded with your application environment and models for testing and debugging. |
| `ofa doctor` | **System Health Check.** Validates `.env` config, database connectivity (SQL/MongoDB), Ruby version, and dependencies. |
| `ofa routes` | **Route Inspection.** Lists all registered routes in your application in a clean tabular format. |
| `ofa swagger` | **OpenAPI Generation.** Auto-generates `openapi.json` for your entire application. |
| `ofa task NAME` | **Run Background Task.** Executes a task defined in `lib/tasks/`. |
| `ofa test` | **Run Test Suite.** Executes all unit tests in the `test/` directory using Minitest. |
| `ofa maintenance on/off` | **Toggle Site Access.** Activates a beautiful maintenance page. Admins can still bypass it to work. |
| `ofa deploy` | **Production Deployment.** Automatically detects deployment targets (Railway/Docker/Git). |

---

### 🏗️ Scaffolding & Generators (`ofa g`)
Automate the creation of boilerplate code with the generator command.

| Command | Description |
| :--- | :--- |
| `ofa g controller NAME` | Creates a new controller in `app/controllers/{name}_controller.rb` with a default `index` action. |
| `ofa g api NAME` | Creates a JSON-based controller in `app/controllers/{name}_controller.rb` inheriting from `ApiController`. |
| `ofa g model NAME` | Generates a database model in `app/models/{name}.rb` integrated with the Sequel ORM. |
| `ofa g migration NAME` | Creates a timestamped migration file in `db/migrations/`. Use this to define your schema changes. |
| `ofa g mailer NAME ACTION` | Generates a new mailer in `app/mailers/` and an ERB template in `app/views/mailers/`. |
| `ofa g task NAME` | Creates a new background task file in `lib/tasks/`. |
| `ofa g test NAME` | Generates a new Minitest unit test in `test/`. |
| `ofa g plugin NAME` | **Plugin Scaffolding.** Creates a new plugin structure in the `plugins/` directory. |
| `ofa g post TITLE` | Creates a new Markdown/ERB post in `app/views/posts/`. <br> *Args:* `--category`, `--author`, `--image`. <br> *Example:* `./ofa g post "My First Journey" --category Tech --author "John Doe"` |

---

### 🎨 Configuration & Customization
Fine-tune your application's behavior and appearance without touching the code.

| Command | Description |
| :--- | :--- |
| `ofa type NAME` | **Set Application Type.** Switches the layout logic between `portfolio`, `blog`, `landing_page`, and `e_commerce`. |
| `ofa theme NAME` | **Change UI Aesthetic.** Instantly swap between premium themes: <br> • `light_glass` / `dark_glass` (Modern Glassmorphism) <br> • `cyber_sidebar` (High-tech) <br> • `retro_terminal` (Old-school hacker vibe) <br> • `light_sidebar` (Professional/Clean) |
| `ofa feature ACTION FEATURE`| **Toggle Core Features.** Enable or disable system modules. <br> *Usage:* `./ofa feature enable auth`, `enable cms`, or `enable rich_text`. |
| `ofa storage NAME` | **Set Media Storage.** Choose between `local` (uploads folder) or `cloudinary` (Cloud storage). |

---

### 🔐 Security & Database
| Command | Description |
| :--- | :--- |
| `ofa reset-password USR PWD`| **Enterprise Recovery.** Resets admin credentials with strict enforcement: 8+ chars, uppercase, and numbers. Powered by BCrypt hashing. |
| `ofa db migrate-data TYPE [NAME]`| **Zero-Loss Migration.** The ultimate tool to move data (Users, Posts, Products) from SQLite to MongoDB Atlas or other SQL DBs without losing a single record. |
| `ofa db switch ADAPTER` | **Hot-swap Engine.** Instantly change your database adapter. Supports `sqlite`, `mysql`, `mariadb`, `postgres`, and `mongodb`. |
| `ofa db migrate` | **Schema Evolution.** Runs all pending migrations. OFA automatically handles table creation for core models during boot for maximum reliability. |

---

## 🏗️ Architecture

OFA follows a strict **MVC (Model-View-Controller)** pattern:

-   **Models**: Powered by **Sequel** for SQL and **Mongo Ruby Driver** for NoSQL.
-   **Views**: High-performance **ERB** templates with a modular design system.
-   **Controllers**: Lightweight logic handlers with built-in validation helpers.
-   **Middleware**: Custom authentication and session sliding expiration (8-hour default).

---

## 🚢 Deployment Guide

One-For-All is designed to be cloud-native and "deploy-ready" from day one.

### 🚂 Railway (Recommended)
Railway is the easiest way to get your OFA app live. The framework includes a `Procfile` that Railway detects automatically.
1. Install [Railway CLI](https://docs.railway.app/guides/cli).
2. Run `railway login`.
3. In your project folder, run:
   ```bash
   ./ofa deploy
   ```
   *The CLI will automatically trigger `railway up` and handle the build process.*

### 🐳 Docker
For customized hosting or VPS providers, use the optimized `Dockerfile`.
1. **Build the image**:
   ```bash
   docker build -t my-ofa-app .
   ```
2. **Run the container**:
   ```bash
   docker run -p 3000:3000 --env-file .env my-ofa-app
   ```
   *Note: Ensure your `.env` contains production-ready database credentials.*

### 🖥️ VPS (DigitalOcean, Linode, AWS)
To run OFA on a raw Linux server:
1. **Setup**: Clone your repo and run `bundle install --deployment`.
2. **Database**: Run `./ofa db migrate` to sync your production schema.
3. **Process Management**: Use [PM2](https://pm2.keymetrics.io/) to keep the server alive:
   ```bash
   pm2 start "./ofa run" --name ofa-app
   ```
4. **Reverse Proxy**: We recommend using **Nginx** as a reverse proxy to handle SSL and port 80/443 forwarding to port 3000.

---

## 🤝 Contributing

We welcome contributions! Please feel free to submit Pull Requests or report issues on the [GitHub repository](https://github.com/ishikawauta/one-for-all-framework).

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.