$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'sequel'
require 'sequel_sanitize'
require 'rspec'
#require 'rspec/autorun'

# Create model to test on
DB = Sequel.sqlite
DB.create_table :items do
  primary_key :id
  String :name
end

class Item < Sequel::Model; end

Spec::Runner.configure do |config|
  config.after(:each)  { Item.delete }
end
