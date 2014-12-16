require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'json'
require_relative 'lib/upload_utils'

# Yes I want logging!

require 'logger'
enable :logging

# How is the server configured?

config_file 'imgupload.config.yml'
set :port, settings.port
set :bind, settings.addr


# Upload a new file

post '/upload' do
  out = { :original => params['file'][:filename] }
  
  # Create current year/month directory
  
  dir = UploadUtils.cal_dir( settings.upload )
  logger.info dir
  
  # Get a unique filename
  
  out[:path] = UploadUtils.uniq_file( "#{dir}/#{out[:original]}" )
  logger.info out[:path]
  
  # Save to upload directory
    
  File.open( out[:path], "w" ) do |f|
    f.write( params['file'][:tempfile].read )
  end
  
  # Extract additional metadata
  
  # Return metadata JSON
  
  return out.to_json
end


# Return a new file

get '/upload' do
  return { :message => "congratulations" }.to_json
end