require_relative '../server_test'

# ruby basic.rb test_upload

class Basic < ServerTest
  
  
  # Upload image from filesystem
  
  def test_upload
    file = File.new( data('img/manuscript.jpg'), 'rb' )
    
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
  
  
  # Resize an image using full src URL
  
  def test_resize
    
    file = File.new( data('img/manuscript.jpg'), 'rb' )
    
    res = RestClient.post(
      serv_path( "upload" ),
      :file => file
    )
    
    json = JSON.parse( res )
    
    res = RestClient.post(
      serv_path( "resize" ),
      :src => json['src'],
      :max_width => 300,
      :max_height => 300
    )
    
    assert( true )
  end
  
  
  # Resize an image using just a partial path
  
  def test_resize_path
    
    file = File.new( data('img/manuscript.jpg'), 'rb' )
    
    res = RestClient.post(
      serv_path( "upload" ),
      :file => file
    )
    
    json = JSON.parse( res )
    
    res = RestClient.post(
      serv_path( "resize" ),
      :src => json['src'],
      :max_width => 300,
      :max_height => 300
    )
    
    assert( true )
  end
  
end