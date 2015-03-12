require 'rubygems'
require 'rake/testtask'
require 'yaml'
require 'erubis'
require 'sidekiq'

@settings = YAML.load( File.read( "imgup.conf.yml" ) )
Rake::TestTask.new do |t|
  t.libs = ['test']
  t.test_files = FileList[ 'test/unit/*rb', 'test/integration/*rb' ]
end

def write_config( name )
  tmpl = "conf/tmpl/#{ name }.tmpl"
  config = path.gsub( 'tmpl/','' ).gsub( '.tmpl', '' )
  write_out( tmpl, config )
end

def write_out( src, to )
  puts "Writing #{to} from template #{src}"
  tmpl = Erubis::Eruby.new( File.read( src ) )
  out = File.open( to, "w" )
  out << tmpl.result( @settings )
  out.close
end


# Meta

desc "Start all imgup's servers"
task :start do
  Rake::Task[:redis].invoke
  Rake::Task[:sidekiq].invoke
  Rake::Task[:sinatra].invoke
end

desc "Build configuration"
task :config do
  Rake::Task['redis:config'].invoke
  Rake::Task['sidekiq:config'].invoke
end

desc "Run redis & sidekiq on system init"
task :sysinit do
  Rake::Task['redis:sysinit'].invoke
  Rake::Task['sidekiq:sysinit'].invoke
end


# Sinatra

desc "Start sinatra"
task :sinatra do
  `ruby imgup.server.rb`
end

namespace :data do
  desc 'Destroy all image data'
  task :destroy do
    STDOUT.puts "Sure you want to destroy all images in #{ @settings["upload"] }, #{ @settings["resize"] }, and #{ @settings["crop"] }? (y/n)"
    input = STDIN.gets.strip
    if input == 'y'
      ["upload","resize","crop"].each do |dir|
        FileUtils.rm_rf( @settings[dir] )
        FileUtils.mkdir( @settings[dir] )
      end
    else
      STDOUT.puts "No data was destroyed.  It's still all there :)"
    end
  end
end


# Redis

desc "Start redis"
task :redis do
  puts 'starting redis...'
  Rake::Task['redis:config'].invoke
  fork do 
    `redis-server conf/redis.conf` 
  end
end

namespace :redis do
  
  desc "Build redis config"
  task :config do
    write_config( 'redis.conf' );
  end
  
  desc "Run redis on system init"
  task :sysinit do
    write_out( 'conf/tmpl/redis.init.d.tmpl', 'conf/redis' )
    `sudo mv conf/redis #{@settings['redis_initd']}`
    `sudo update-rc.d redis defaults 98`
  end
  
end


# Sidekiq

desc "Start sidekiq"
task :sidekiq do
  puts 'starting sidekiq...'
  Rake::Task['sidekiq:config'].invoke
  fork do 
    `touch #{ @settings['sidekiq_log' ] }`
    `bundle exec sidekiq -C conf/sidekiq.yml -d -L #{ @settings['sidekiq_log' ] } -r #{File.dirname(__FILE__)}/imgup.server.rb` 
  end
end

namespace :sidekiq do
  
  desc "Stop sidekiq"
  task :stop do
    Process.kill( 15, File.read( @settings['sidekiq_pid'] ).to_i )
  end
  
  desc "Build sidekiq config"
  task :config do
    write_config( 'sidekiq.yml' );
  end
  
  desc "Run sidekiq on system init"
  task :sysinit do
    write_out( 'conf/tmpl/sidekiq.init.d.tmpl', 'conf/sidekiq' )
    `sudo mv conf/sidekiq #{@settings['sidekiq_initd']}`
    `sudo update-rc.d sidekiq defaults 99`
  end
  
end

namespace :stats do
  desc "Clear sidekiq monitor stats"
  task :clear do
    Sidekiq.redis {|c| c.del('stat:processed') }
    Sidekiq.redis {|c| c.del('stat:failed') }
  end
end

desc "Start sidekiq monitor :#{ @settings['sidekiq_port'] }"
task :monitor do
  require 'sidekiq/web'
  app = Sidekiq::Web
  app.set :environment, :production
  app.set :bind, '0.0.0.0'
  app.set :port, @settings['sidekiq_port']
  app.run!
end

