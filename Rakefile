require 'rubygems'
require 'rake/testtask'
require 'yaml'

@settings = YAML.load( File.read( "imgupload.config.yml" ) )
Rake::TestTask.new do |t|
  t.libs = ['test']
  t.warning = true
  t.verbose = true
  t.test_files = FileList[ 'test/unit/*rb', 'test/integration/*rb' ]
end

desc "Run tests"
task :default => :test

desc "Start server"
task :start do
  `ruby imgupload.server.rb`
end