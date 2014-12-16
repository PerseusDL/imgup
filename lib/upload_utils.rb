class UploadUtils
  
  
  # Create a YEAR/MONTH directory
  # ex. dir/2014/FEB -- dir/2014/JAN/sub
  
  def self.cal_dir( dir, sub='' )
    time = Time.now
    dir = File.join( dir, time.year.to_s, time.strftime( '%^b' ), sub )
    FileUtils.mkdir_p( dir )
    return dir
  end
  
  
  # Get a unique filename
  
  def self.uniq_file( file, n=1 )
    
    #  Determine the suffix of the uploaded filename
    
    count = ''
    if n > 1
      count = ' ' + n.to_s
    end

    #  Build the new path
    
    dir = File.dirname( file )
    ext = File.extname( file )
    base = File.basename( file, ext )
    nf = base + count + ext
    path = File.join( dir, nf )
    
    #  Check to see if the file exists already
    
    if File.file?( path )
      n += 1
      return uniq_file( file, n )
    end
    
    # You have a unique filename
    
    return path
  end
  
end