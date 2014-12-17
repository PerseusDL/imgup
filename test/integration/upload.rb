require_relative '../server_test'

# ruby upload.rb test_AAA_upload

class Upload < ServerTest
  
  def test_AAA_upload
    file = File.new( data('manuscript.jpg'), 'rb' )
    
    res = RestClient.post(
      serv_path( "upload" ),
      :file => file
    )
    
    puts res.inspect
    assert( false )
  end
  
  def test_AAB_link
    
    res = RestClient.post(
      serv_path( "src" ),
      :src => "http://meathaus.com/wp-content/uploads/tumblr_n9n8w7ZYbu1swwc27o1_1280.jpg"
    )
    
    puts res.inspect
    assert( false )
  end
  
end