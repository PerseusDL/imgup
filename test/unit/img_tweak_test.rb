require_relative '../server_test'
require_relative '../../lib/img_tweak'

# ruby basic.rb test_resize

class ImgTweakTest < ServerTest
  
  
  # Resize an image
  
  def test_resize
    tmp = temp('manuscript.jpg')
    src = data('manuscript.jpg' )
    max = 200;
    ImgTweak.resize( src, tmp, "#{max}x#{max}" );
    dim = ImgTweak.dim( tmp )
    File.delete( tmp )
    assert( dim[:width] <= max && dim[:height] <= max )
  end
  
end