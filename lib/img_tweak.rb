require 'mini_magick'

class ImgTweak
  
  # Resize image
  # size @string "100x100"
  
  def self.resize( src, out, size )
    img = MiniMagick::Image.open( src )
    img.resize( size )
    img.format( 'jpg' )
    img.write( out )
  end
  
  
  # Get file dimensions
  
  def self.dim( src )
    img = MiniMagick::Image.open( src )
    { :width => img['width'], :height => img['height']  }
  end
  
  
  # Convert to image format
  
  def self.convert( src, type )
  end
  
end