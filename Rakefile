require 'rubygems'
require 'rake/testtask'
require 'yaml'

@settings = YAML.load( File.read( "imgup.config.yml" ) )
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
  `ruby imgup.server.rb`
end

namespace :data do
  desc 'Destroy all image data'
  task :destroy do
    STDOUT.puts "Sure you want to destroy all images in \"#{@settings["upload"]}/\"? (y/n)"
    input = STDIN.gets.strip
    if input == 'y'
      FileUtils.rm_rf( @settings["upload"] )
      FileUtils.mkdir( @settings["upload"] )
    else
      STDOUT.puts "No data was destroyed.  It's still all there :)"
    end
  end
end