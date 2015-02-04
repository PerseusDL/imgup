require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'sinatra/cross_origin'
require 'json'
require 'net/http'
require 'open-uri'
require_relative 'lib/upload_utils'
require_relative 'lib/img_meta'
require_relative 'lib/sidekiq/size_worker'

# Yes I want logging!

require 'logger'
enable :logging
enable :cross_origin

# How is the server configured?

config_file 'conf/imgup.conf.yml'
set :port, settings.port
set :bind, settings.addr

before do
    logger.level = Logger::DEBUG
end

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
  
  
  # Return a 500 error
  
  def fatal_error( err, code=500 )
    status code
    { :error => err }.to_json
  end
  
  
  # Spit out a file
  
  def spit_file( file )
    # make sure file is in an approved of directory
    send_file open( file ), type: ImgMeta.type( file ), disposition: 'inline'
  end
  
  
  # Log output
  
  def logdump( obj )
    logger.debug obj.inspect
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
  
  
  # Create current resize directory
  
  def resize_dir
    UploadUtils.cal_dir( settings.resize )
  end
  
  
  # Get local directory from URL
  
  def local( src )
    esc = URI.escape( src )  
    begin
      uri = URI( esc )
      path = uri.path
    rescue
      path = uri
    end
    if path.chars.first == '/'
      path = path[1..-1]
    end
    URI.unescape( path )
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
  
  
  # CORS Cross Origin Resource Sharing
  # aka "allow requests from"
  
  def cors
    cross_origin :allow_origin => settings.allow_origin
  end
  
end



#######################
# CONTROLLER METHODS


# Upload a new file

post '/upload' do
  cors
  begin
    if params.has_key? 'file'
      out = { :orig => params['file'][:filename] }
      upload( out, params['file'][:tempfile] )
    else
      src = JSON.parse( request.body.read )["src"]
      out = { :orig => src }
      upload( out, src )
    end
  rescue
      status 500
      { :error => "Error uploading..." }.to_json
  end
end

options '/upload' do
  cors
end


# Upload a zip containing many files

post '/zip' do
  cors
  fatal_error( "feature not complete" )
end


# Retrieve a new file from the web

post '/src' do
  cors
  out = { :orig => params['src'] }
  upload( out, params['src'] )
end


# Resize an existing image

post '/resize' do
  cors
  
  # Get the local path to source file
  
  src = local( params['src'] )
  
  # Make sure path is valid
  
  if File.exist?( src ) == false
    fatal_error( "#{params['src']} not found" )
  end
  
  # Claim resize home
  
  resize = UploadUtils.uniq_file( "#{resize_dir}/#{ File.basename( src )}" )
  
  # Copy placeholder
  
  FileUtils.cp( 'public/img/processing.jpg', resize )
  
  # Kick off resize process
  max_width = params['max_width']
  max_height = params['max_height']
  
  SizeWorker.perform_async( src, resize, "#{max_width}x#{max_height}" )
  
  # Return path of the resized file
  
  return { 'src' => resize }.to_json
  
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