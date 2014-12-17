require 'exifr'
require 'mimemagic'

class ImgMeta
  
  # Get the type
  
  def self.type( file )
    ::MimeMagic.by_path( file )
  end
  
  
  # Retrieve EXIF data
  
  def self.exif( file )
    format = format.to_s.upcase
    
    #  Is the file a JPEG?
    
    type = self.type( file ).to_s.upcase
    if type != 'IMAGE/JPEG'
      raise "File format ( #{ type } ) is not supported"
    end

    #  Get the EXIFR data
    
    hash = {}
    jpeg = self.exif_jpeg( file )
    if jpeg.exif? == false
      return hash
    end
    
    hash = jpeg.exif[0].to_hash

    #  Some values need to have their types converted
    
    hash[:orientation] = nil
    hash[:date_time] = hash[:date_time].to_i
    hash[:date_time_original] = hash[:date_time_original].to_i
    hash[:date_time_digitized] = hash[:date_time_digitized].to_i

    #  And you're out!
    
    return hash
    
  end
  
  
  # Retrieve EXIF data from a JPEG
  
  def self.exif_jpeg( file )
    return EXIFR::JPEG.new( file )
  end
  
end