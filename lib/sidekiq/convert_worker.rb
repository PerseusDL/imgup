require_relative '../img_tweak'
require 'sidekiq'
class ConvertWorker
  include Sidekiq::Worker
  sidekiq_options queue: "convert"
  
  def perform( src, out, type )
  end
end