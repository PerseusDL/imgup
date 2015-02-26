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
  
  
  # Crop image
  # x, y, width, height use relative values
  # ( floats between 0 and 1 )
  
  def self.crop( src, out, x, y, width, height )
    img = MiniMagick::Image.open( src )
    px_w = ( img[:width] * width.to_f ).floor
    px_h = ( img[:height ] * height.to_f ).floor
    px_x = ( img[:width] * x.to_f ).floor
    px_y = ( img[:height] * y.to_f ).floor
    img.crop( "#{px_w}x#{px_h}+#{px_x}+#{px_y}" )
    img.write( out )
  end
  
  
  # Convert to image type
  # type @string "jpg"
  
  def self.make( src, out, type )
    img = MiniMagick::Image.open( src )
    img.format( type )
    img.write( out )
  end
  
  
  # Get image type
  
  def self.type( src )
    img = MiniMagick::Image.open( src )
    img.type
  end
  
end