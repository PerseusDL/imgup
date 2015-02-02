require 'rubygems'
require 'rake/testtask'
require 'yaml'

@settings = YAML.load( File.read( "conf/imgup.conf.yml" ) )
Rake::TestTask.new do |t|
  t.libs = ['test']
  t.warning = true
  t.verbose = true
  t.test_files = FileList[ 'test/unit/*rb', 'test/integration/*rb' ]
end

desc "run tests"
task :default => :test

desc "start imgup server"
task :start do
  `ruby imgup.server.rb`
end

desc "start redis"
task :redis do
  `redis-server conf/redis.conf`
end

desc "start sidekiq"
task :sidekiq do
  `bundle exec sidekiq -C conf/sidekiq.yml -d -L log/sidekiq.log -r #{File.dirname(__FILE__)}/imgup.server.rb`
end

SIDEKIQ_UI_PORT = 9494
desc "start sidekiq monitor :#{SIDEKIQ_UI_PORT}"
task :monitor do
  require 'sidekiq/web'
  app = Sidekiq::Web
  app.set :environment, :production
  app.set :bind, '0.0.0.0'
  app.set :port, SIDEKIQ_UI_PORT
  app.run!
end

namespace :data do
  desc 'destroy all image data'
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