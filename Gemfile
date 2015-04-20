source 'https://rubygems.org'

group :development do
  gem "byebug"
  gem "looksee"
end

group :development, :test do
  gem "bundler",       "~> 1.9.1"
  gem "rake",          "~> 10.0"
  gem "pry"
end

group :test do
  gem "database_cleaner",   "~> 1.3.0"
  gem "actionpack"          # used by combustion
  gem "faker"
  gem "rspec-rails",        "~> 3.2"
  gem "combustion",         "~> 0.5.3"
  gem "serial-spec",        "~> 0.3.0"
  gem "machinist-mongoid",  "~> 0.1.0"
end

gemspec
