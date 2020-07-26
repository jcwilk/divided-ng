source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.1"

gem "bootsnap", ">= 1.4.2", require: false
gem "grape"
gem "grape-roar"
gem "hashie"
gem "jbuilder", "~> 2.7"
gem "multi_json"
gem "pg", ">= 0.18", "< 2.0"
gem "rails", "~> 6.0.3", ">= 6.0.3.2"
gem "roar"
gem "slim-rails"
gem "thin"
gem "webpacker", "~> 4.0"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"
# Use Active Model has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use Active Storage variant
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem "pry-byebug"
  gem "rspec-rails"
end

group :development do
  gem "listen", "~> 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "hyperresource"
  gem "mock_em"
  gem "rspec-its"
end
