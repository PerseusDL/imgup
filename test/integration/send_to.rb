require_relative '../server_test'

# ruby send_to.rb test_resize

# It is really hard to write tests for this,
# because it is asynchronous.

# I'll have to manually run these until I figure out
# a system for doing this.

class SendTo < ServerTest
  
  # Resize image with send_to callback
  
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
      :max_height => 300,
      :send_to => 'http://localhost:4567/data/imgup/test/urn:cite:imgup.resizeTest',
      :json => File.read( data('json/resize_test.json') )
    )
    
    puts res.inspect
  end
  
end