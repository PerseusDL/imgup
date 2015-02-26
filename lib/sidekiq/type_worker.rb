require 'sidekiq'

class CropWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: "type"
  
  def perform( src, out, type, send_to, json, url_prefix )
    ImgTweak.make( src, out, type )
  end
end