require_relative '../server_test'

# ruby basic.rb --name test_crop

class Basic < ServerTest
  
  def test_crop
    file = File.new( data('img/manuscript.jpg'), 'rb' )
    
    res = RestClient.post(
      serv_path( "upload" ),
      :file => file
    )
    
    json = JSON.parse( res )
    
    res = RestClient.post(
      serv_path( "crop" ),
      :src => json['src'],
      :x => 0.2,
      :y => 0.2,
      :width => 0.5,
      :height => 0.5 
    )
    
    assert( true )
  end
  
  
  # Upload image from filesystem
  
  def test_upload
    file = File.new( data('img/manuscript.jpg'), 'rb' )
    
    res = RestClient.post(
      serv_path( "upload" ),
      :file => file
    )

    assert( false )
  end
  
  
  # Upload image from webserver
  
  def test_src
    
    res = RestClient.post(
      serv_path( "src" ),
      :src => "http://meathaus.com/wp-content/uploads/tumblr_n9n8w7ZYbu1swwc27o1_1280.jpg"
    )
    
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