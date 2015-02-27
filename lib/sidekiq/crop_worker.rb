require 'sidekiq'

class CropWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: "crop"
  
  def perform( src, out, x, y, width, height, send_to, json, url_prefix )
    ImgTweak.crop( src, out, x, y, width, height )
    
    if json != nil && send_to != nil
      
      # Update the JSON with data from newly resized image
      
      hash = json
      if json.is_a?( String )
        hash = JSON.parse( json )
      end
      HashUtils.change_hash( hash, { 
        'src' => Addressable::URI.escape( "#{url_prefix}/#{out}" ),
      })
      
      # Update the JackSON server with the JSON metadata
            
      RestClient.post( send_to, { :data => hash }.to_json )
      
    end
    
  end
end