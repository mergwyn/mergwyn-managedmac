require 'simplecov'

if ENV['SIMPLECOV']
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
  SimpleCov.start { add_filter '/spec/' }
elsif ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
  SimpleCov.start do
    track_files 'lib/**/*.rb'
    add_filter '/spec'
    add_filter '/vendor'
    add_filter '/.vendor'
  end
end

require_relative './helpers'
RSpec.configure do |c|
  c.include Helpers
end
