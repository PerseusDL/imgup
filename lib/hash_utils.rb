class HashUtils
  
  # Update a hash by interpolating values stored in a map object
  
  def self.change_hash( hash, map )
    hash.each do | key, val |
      
      if val.is_a?( Hash )
        self.change_hash( val, map )
      end
      
      if val.is_a?( String )
        map.each do | mkey, mval |
          val.sub!( "{{ #{mkey} }}", "#{mval}" )
          # What to do about individual numbers?
        end
      end
      
    end
    hash
  end
  
end