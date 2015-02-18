require_relative '../img_tweak'
require 'sidekiq'
class CropWorker
  include Sidekiq::Worker
  sidekiq_options queue: "crop"
  
  def perform( src, out, x, y, width, height )
    ImgTweak.crop( src, out, x, y, width, height )
  end
end