require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'sinatra/cross_origin'
require 'json'
require 'net/http'
require 'open-uri'
require_relative 'lib/upload_utils'
require_relative 'lib/img_meta'

# Yes I want logging!

require 'logger'
enable :logging
enable :cross_origin

# How is the server configured?

config_file 'imgup.config.yml'
set :port, settings.port
set :bind, settings.addr


#######################
# SHARED HELPER METHODS

helpers do
  
  
  # Return exif metadata about an image
  
  def exif( file )
    begin
      ImgMeta.exif( file )
    rescue Exception => e
      { :error => e.message }
    end
  end
  
  
  # Retrieve path from request URL
  
  def path( params )
    params[:splat][0]
  end
  
  
  # Return a 404 error
  
  def fatal_error( err, code=500 )
    status code
    { :error => err }.to_json
  end
  
  
  # Spit out a file
  
  def spit_file( file )
    send_file open( file ), type: ImgMeta.type( file ), disposition: 'inline'
  end
  
  
  # Run a command on a path
  
  def run( cmd, pth )
    
    # No command no action
    
    if cmd == nil
      return fatal_error( "No command was passed to ?cmd=" )
    end
    
    
    case cmd
    
    # exif metadata
    
    when 'exif'
      if File.file?( pth ) == false
        return fatal_error( "#{pth} could not be found", 404 )
      end
      return exif( pth )
    
    # Invalid command
    
    else
      return fatal_error( "#{cmd} is not a valid command" )
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
    
    out[:src] = "http://#{request.host_with_port}/#{path}"
  
    # Extract additional metadata
  
    out[:exif] = exif( path )
  
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
  
  
  # Allow requests from origin
  
  def allow_origin
    settings.allow_origin.each do | host |
      cross_origin :allow_origin => host
    end
  end
  
end



#######################
# CONTROLLER METHODS


# Upload a new file

post '/upload' do
  allow_origin
  out = { :orig => params['file'][:filename] }
  upload( out, params['file'][:tempfile] )
end

options '/upload' do
  allow_origin
end


# Upload a zip containing many files

post '/zip' do
  allow_origin
  fatal_error( "feature not complete" )
end


# Retrieve a new file from the web

post '/src' do
  allow_origin
  out = { :orig => params['src'] }
  upload( out, params['src'] )
end


# Return an image or run a command

get '/*' do
  
  pth = path( params )
  if params.has_key?('cmd')
    return run( params['cmd'], pth ).to_json
  end
  
  begin
    spit_file( pth )
  rescue
    fatal_error( "file not found", 404 )
  end
  
end