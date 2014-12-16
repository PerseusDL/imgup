require_relative '../server_test'

# ruby upload.rb test_AAA_upload

class Upload < ServerTest
  
  def test_AAA_upload
    url = "http://localhost:#{ @@settings['port'] }/upload"
    file = File.new( data('manuscript.jpg'), 'rb' )
    res = RestClient.post(
      url,
      :file => file
    )
    assert( false )
  end
  
  def test_AAB_link
    puts 'link'
    assert( false )
  end
  
end