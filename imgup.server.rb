require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'json'
require 'net/http'
require_relative 'lib/upload_utils'
require_relative 'lib/img_meta'

# Yes I want logging!

require 'logger'
enable :logging

# How is the server configured?

config_file 'imgup.config.yml'
set :port, settings.port
set :bind, settings.addr


#######################
# SHARED HELPER METHODS

helpers do
  
  
  # Return exif metadata about an image
  
  def exif( file )
    ImgMeta.exif( file )
  end
  
  
  # Retrieve path from request URL
  
  def path( params )
    params[:splat][0]
  end
  
  
  # Return an error
  
  def error( err )
    status 404
    { :error => err }.to_json
  end
  
  
  # Spit out a file
  
  def spit_file( file )
    send_file file
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
  
  
  # Create current upload directory
  
  def up_dir
    UploadUtils.cal_dir( settings.upload )
  end
  
  
  # Handles uploads from file or URL
  
  def upload( out, src )
    
    # Get a unique file path
  
    path = ''
    if UploadUtils.uri?( src )
      path = UploadUtils.uniq_file( "#{up_dir}/#{ File.basename( out[:orig])}" )
      cp_http( src, path )
    else
      path = UploadUtils.uniq_file( "#{up_dir}/#{out[:orig]}" )
      cp_fs( src, path )
    end
    
    # Save new path
    
    out[:path] = path
  
    # Extract additional metadata
  
    out[:exif] = exif( out[:path] )
  
    # Return metadata JSON
  
    return out.to_json
  end
  
  
  # Copy a file from the filesystem or over HTTP
  
  def cp_fs( src, dest )
    FileUtils.cp( src, dest )
  end
  
  
  # Copy a file over HTTP
  
  def cp_http( src, dest )
    uri = URI.parse( src )
    Net::HTTP.start( uri.host ) do |http|
      res = http.get( uri.path )
      open( dest, 'wb' ) do |out|
        out.write( res.body )
      end
    end
  end
  
end



#######################
# CONTROLLER METHODS

# Upload a new file

post '/upload' do
  out = { :orig => params['file'][:filename] }
  upload( out, params['file'][:tempfile] )
end

# Upload a zip containing many files

post '/zip' do
  error( "feature not complete" )
end


# Retrieve a new file from the web

post '/src' do
  out = { :orig => params['src'] }
  upload( out, params['src'] )
end


# Return an image or run a command

get '/*' do
  
  pth = path( params )
  if params.has_key?('cmd')
    return run( params['cmd'], pth )
  end
  
  begin
    spit_file( pth )
  rescue
    error( "file not found" )
  end
  
end