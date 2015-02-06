require 'sidekiq'

class SizeWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: "resize"
  
  def perform( src, out, size, send_to, json, url_prefix )
    ImgTweak.resize( src, out, size )
    
    if json != nil && send_to != nil
      
      # Update the JSON with data from newly resized image
      
      dim = ImgTweak.dim( out )
      hash = json
      if json.is_a?( String )
        hash = JSON.parse( json )
      end
      HashUtils.change_hash( hash, { 
        'src' => "#{url_prefix}/#{out}", 
        'width' => dim[:width], 
        'height' => dim[:height] 
      })
      
      # Update the JackSON server with the JSON metadata
            
      RestClient.post( send_to, { :data => hash }.to_json )
      
    end
  end
  
end