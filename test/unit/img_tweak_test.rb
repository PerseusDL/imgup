require_relative '../server_test'
require_relative '../../lib/img_tweak'

# ruby basic.rb test_resize

class ImgTweakTest < ServerTest
  
  
  # Resize an image
  
  def test_resize
    tmp = temp('manuscript.jpg')
    src = data('img/manuscript.jpg' )
    max = 200;
    ImgTweak.resize( src, tmp, "#{max}x#{max}" );
    dim = ImgTweak.dim( tmp )
    File.delete( tmp )
    assert( dim[:width] <= max && dim[:height] <= max )
  end
  
  
  # Crop an image
  
  def test_crop
    tmp = temp('manuscript.jpg')
    src = data('img/manuscript.jpg')
    dim = ImgTweak.dim( tmp )
    puts dim.inspect
    ImgTweak.crop( src, tmp, 0.2, 0.2, 0.5, 0.5 )
    # File.delete( tmp )
    assert( true == true )
  end
  
end