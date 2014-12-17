require 'minitest'
require 'minitest/autorun'
require 'benchmark'
require 'rest_client'
require 'json'
require 'yaml'

class ServerTest < Minitest::Test
  
  # Config will be handy for testing
  
  @@settings = YAML.load( File.read("#{File.dirname(__FILE__)}/../imgup.config.yml") )
  def self.settings
    @@settings
  end
  
  def self.test_order
    :alpha
  end
  
  private
  
  def dir
    File.dirname(__FILE__)
  end
  
  def data( file )
    "#{dir()}/data/#{file}"
  end
  
  def serv_path( pth )
    "http://localhost:#{ @@settings['port'] }/#{ pth }"
  end
end