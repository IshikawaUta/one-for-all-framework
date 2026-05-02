<p align="center">
  <img src="public/images/logo.png" width="500" height="500" alt="OFA Framework Logo">
</p>

# ⚡ One-For-All (OFA) Framework v3.0.0

[![Ruby Version](https://img.shields.io/badge/ruby-%3E%3D%203.0.0-red.svg)](https://www.ruby-lang.org/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Framework](https://img.shields.io/badge/MVC-Lightweight-orange.svg)]()

**One-For-All (OFA)** is a premium, ultra-fast Ruby MVC framework designed for developers who value both high performance and modern aesthetics. Built on the powerful **Eks-Cent** engine and optimized with **Eksa Server**, OFA v3.0 now supports **Full E-Commerce integration** alongside its stunning "Glassmorphism" UI.

---

## ✨ Why One-For-All?

-   **💎 Premium Aesthetics**: Beautiful Glassmorphism design system included by default with smooth dark/light mode transitions.
-   **🚀 Blazing Fast**: Built on a modular Nio4r-powered engine for minimal overhead and instant boot times.
-   **📂 Multi-Database**: Seamlessly switch between SQLite, MySQL, MariaDB, and MongoDB Atlas.
-   **🛠️ Developer First**: A robust CLI (`ofa`) that handles everything from scaffolding to deployment.
-   **🔐 Enterprise Ready**: Built-in CSRF protection, secure session management, and input validation.
-   **🌐 Global Support**: Multi-language (I18n) support and SEO optimization ready.

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

## 🛠️ CLI Power Tools (Detailed Reference)

The `ofa` CLI is the heart of the One-For-All framework. It handles everything from project initialization to production deployment.

### 📁 Project Lifecycle
| Command | Description |
| :--- | :--- |
| `ofa new NAME [TYPE]` | **Create a new project.** Generates a new directory, initializes the framework structure, and automatically runs `bundle install`. <br> *Example:* `./ofa new my_portfolio portfolio` |
| `ofa init [TYPE]` | **Initialize in current folder.** Ideal if you've already created a folder or cloned a repository. It triggers an **Interactive Wizard** to configure your Database (SQLite/MongoDB) and Image Storage (Local/Cloudinary). |
| `ofa run` | **Start Development Server.** Boots the high-performance Eksa Server. Your app will be accessible at `http://localhost:3000`. |
| `ofa deploy` | **Production Deployment.** Automatically detects deployment targets. <br> 1. Checks if it's a Git repository. <br> 2. Detects **Railway CLI** and triggers `railway up`. <br> 3. Supports Docker via the included `Dockerfile`. |

---

### 🏗️ Scaffolding & Generators (`ofa g`)
Automate the creation of boilerplate code with the generator command.

| Command | Description |
| :--- | :--- |
| `ofa g controller NAME` | Creates a new controller in `app/controllers/{name}_controller.rb` with a default `index` action. |
| `ofa g model NAME` | Generates a database model in `app/models/{name}.rb` integrated with the Sequel ORM. |
| `ofa g migration NAME` | Creates a timestamped migration file in `db/migrations/`. Use this to define your schema changes. |
| `ofa g post TITLE` | Creates a new Markdown/ERB post in `app/views/posts/`. <br> *Args:* `--category`, `--author`, `--image`. <br> *Example:* `./ofa g post "My First Journey" --category Tech --author "John Doe"` |

---

### 🎨 Configuration & Customization
Fine-tune your application's behavior and appearance without touching the code.

| Command | Description |
| :--- | :--- |
| `ofa type NAME` | **Set Application Type.** Switches the layout logic between `portfolio`, `blog`, `landing_page`, and `e_commerce`. |
| `ofa theme NAME` | **Change UI Aesthetic.** Instantly swap between premium themes: <br> • `light_glass` / `dark_glass` (Modern Glassmorphism) <br> • `cyber_sidebar` (High-tech) <br> • `retro_terminal` (Old-school hacker vibe) <br> • `light_sidebar` (Professional/Clean) |
| `ofa feature ACTION FEATURE`| **Toggle Core Features.** Enable or disable system modules. <br> *Usage:* `./ofa feature enable auth` or `./ofa feature disable cms`. |
| `ofa storage NAME` | **Set Media Storage.** Choose between `local` (uploads folder) or `cloudinary` (Cloud storage). |

---

### 🔐 Security & Database
| Command | Description |
| :--- | :--- |
| `ofa reset-password USR PWD`| **User Management.** Resets a password for an existing admin or creates a new one. <br> *Note:* Enforces strong password rules (8+ chars, 1 uppercase, 1 number). |
| `ofa db switch ADAPTER` | **Hot-swap Database.** Configure your adapter on the fly: `sqlite`, `mysql`, `mariadb`, `postgres`, or `env` (for MongoDB Atlas). |
| `ofa db migrate` | **Database Sync.** Runs all pending migrations in `db/migrations/` to keep your schema up to date. |

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