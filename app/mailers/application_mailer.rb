require 'mail'
require 'erb'

class ApplicationMailer
  # Configure default settings if needed
  def self.mail(to:, subject:, template:, locals: {})
    # Template name expected: "welcome_mailer/welcome"
    template_path = File.join(APP_ROOT, 'app', 'views', 'mailers', "#{template}.erb")
    
    unless File.exist?(template_path)
      puts "❌ Mailer Error: Template not found at #{template_path}"
      return
    end

    # Create rendering context
    context = Object.new
    locals.each { |k, v| context.instance_variable_set("@#{k}", v) }
    
    body_content = ERB.new(File.read(template_path)).result(context.instance_eval { binding })

    mail = Mail.new do
      from    ENV['MAILER_FROM'] || 'admin@example.com'
      to      to
      subject subject
      body    body_content
      
      # Optional: set content type to HTML if needed
      # content_type 'text/html; charset=UTF-8'
    end

    # In development/test, we might want to just log it
    if ENV['EKS_ENV'] == 'production'
      mail.deliver!
    else
      puts "--- 📧 EMAIL SENT ---"
      puts "To:      #{to}"
      puts "Subject: #{subject}"
      puts "Body:\n#{body_content}"
      puts "----------------------"
    end
  end
end
