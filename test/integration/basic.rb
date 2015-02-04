require_relative '../server_test'

# ruby basic.rb test_upload

class Upload < ServerTest
  
  
  # Upload image from filesystem
  
  def test_upload
    file = File.new( data('manuscript.jpg'), 'rb' )
    
    res = RestClient.post(
      serv_path( "upload" ),
      :file => file
    )
    
    puts res.inspect
    assert( false )
  end
  
  
  # Upload image from webserver
  
  def test_src
    
    res = RestClient.post(
      serv_path( "src" ),
      :src => "http://meathaus.com/wp-content/uploads/tumblr_n9n8w7ZYbu1swwc27o1_1280.jpg"
    )
    
    puts res.inspect
    assert( false )
  end
  
  
  # Resize an image
  
  def test_resize
    
    file = File.new( data('manuscript.jpg'), 'rb' )
    
    res = RestClient.post(
      serv_path( "upload" ),
      :file => file
    )
    
    json = JSON.parse( res )
    
    res = RestClient.post(
      serv_path( "resize" ),
      :src => json['src'],
      :max_width => 100,
      :max_height => 50
    )
    
    puts res.inspect
    assert( true )
  end
  
end