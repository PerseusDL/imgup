require_relative '../img_tweak'
require 'sidekiq'
class SizeWorker
  include Sidekiq::Worker
  sidekiq_options queue: "resize"
  
  def perform( src, out, size, send_to, json )
    ImgTweak.resize( src, out, size )
    
    # If json file and send_to aren't nil
    
    if json != nil && send_to != nil
      
    end
    
  end
end