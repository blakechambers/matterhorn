source 'https://rubygems.org'

group :development do
  gem "byebug"
  gem "looksee"
end

group :development, :test do
  gem "bundler"
  gem "rake",          "~> 10.0"
end

group :test do
  gem 'simplecov',                      require: false
  gem 'coveralls',                      require: false
  gem "database_cleaner",   "~> 1.3.0"
  gem "actionpack"          # used by combustion
  gem "rspec-rails",        "~> 3.2"
  gem "combustion",         "~> 0.5.3"
  gem "serial-spec",        "~> 0.4.1"
  gem "machinist-mongoid",  "~> 0.1.0"
  gem "kaminari",                   "~> 0.14.1"
end

gemspec
