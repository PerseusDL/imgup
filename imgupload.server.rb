require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'json'
require_relative 'lib/upload_utils'
require_relative 'lib/img_meta'

# Yes I want logging!

require 'logger'
enable :logging

# How is the server configured?

config_file 'imgupload.config.yml'
set :port, settings.port
set :bind, settings.addr


helpers do
  
  def exif( file )
    ImgMeta.exif( file )
  end
  
  def path( params )
    params[:splat][0]
  end
  
  def error( err )
    status 404
    { :error => err }.to_json
  end
  
  # Run a command on a path
  
  def run( cmd, pth )
    
    # No command no action
    
    if cmd == nil
      return error( "No command was passed to ?cmd=" )
    end
    
    
    case cmd
    
    # exif metadata
    
    when 'exif'
      if File.file?( pth ) == false
        return error( "#{pth} could not be found" )
      end
      return exif( pth ).to_json
    
    # Invalid command
    
    else
      return error( "#{cmd} is not a valid command" )
    end
  end
  
end


# Upload a new file

post '/upload' do
  out = { :orig => params['file'][:filename] }
  
  # Create current year/month directory
  
  dir = UploadUtils.cal_dir( settings.upload )
  
  # Get a unique filename
  
  out[:path] = UploadUtils.uniq_file( "#{dir}/#{out[:orig]}" )
  
  # Save to upload directory
    
  File.open( out[:path], "w" ) do |f|
    f.write( params['file'][:tempfile].read )
  end
  
  # Extract additional metadata
  
  out[:exif] = exif( out[:path] )
  
  # Return metadata JSON
  
  return out.to_json
end


# Retrieve a new file from the web

post '/src' do
  out = { :orig => params['src'] }
end


# Return an image or run a command

get '/*' do
  pth = path( params )
  if params.has_key?('cmd')
    return run( params['cmd'], pth )
  end
  return { :message => "congratulations" }.to_json
end