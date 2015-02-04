require_relative '../img_tweak'
require 'sidekiq'
class SizeWorker
  include Sidekiq::Worker
  sidekiq_options queue: "resize"
  
  def perform( src, out, size )
    ImgTweak.resize( src, out, size )
  end
end