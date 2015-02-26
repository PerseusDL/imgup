require_relative '../server_test'
require_relative '../../lib/img_tweak'

# ruby basic.rb -- name test_resize

class ImgTweakTest < ServerTest
  
  
  # Resize an image
  
  def test_resize
    tmp = temp( 'manuscript.jpg' )
    src = data( 'img/manuscript.jpg' )
    max = 200;
    ImgTweak.resize( src, tmp, "#{max}x#{max}" );
    dim = ImgTweak.dim( tmp )
    File.delete( tmp )
    assert( dim[:width] <= max && dim[:height] <= max )
  end
  
  
  # Crop an image
  
  def test_crop
    tmp = temp( 'manuscript.jpg' )
    src = data( 'img/manuscript.jpg' )
    
    # Crop the image
    
    wc = 0.5
    hc = 0.5
    ImgTweak.crop( src, tmp, 0.2, 0.2, wc, hc )
    
    # Compare dimensions
    
    dim = ImgTweak.dim( src )
    dim2 = ImgTweak.dim( tmp )
    File.delete( tmp )
    bw = dim2[:width]/wc
    bh = dim2[:height]/hc
    assert( dim[:width] == bw && dim[:height] == bh )
  end
  
  
  # Convert a tiff to jpeg
  
  def test_tiff_to_jpeg
    type = 'JPEG'
    tmp = temp( 'bodin.jpg' )
    src = data( 'img/bodin.tiff' )
    ImgTweak.make( src, tmp, type );
    ts = ImgTweak.type( src )
    tt = ImgTweak.type( tmp )
    File.delete( tmp )
    assert( ts == 'TIFF' && tt == type )
  end
  
end