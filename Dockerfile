FROM ruby:3.2-slim

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libsqlite3-dev

# Set working directory
WORKDIR /app

# Copy files
COPY . .

# Install gems
RUN bundle install

# Expose port
EXPOSE 3000

# Start command
CMD ["bundle", "exec", "ofa", "run"]
