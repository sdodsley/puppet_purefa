require 'net/http'
require 'puppet/purestorage'

Puppet::Type.type(:purefa_volume).provide(:purefa_volume) do
    desc "Provider for type Pure Storage purefa_volume."

    def create
       Puppet.debug("<<<<<<<<<< Inside purefa_volume create & operation:"+@operation)	
      executeVolumeRestApi(@operation,@volume_name,@volume_size)	
    end

    def destroy
       Puppet.debug("<<<<<<<<<< Inside purefa_volume destroy & operation:"+@operation)
      executeVolumeRestApi(@operation,@volume_name,@volume_size)	
    end

    def exists?
      Puppet.debug("<<<<<<<<<< Inside purefa_volume exists?")
      @volume_name =  resource[:volume_name]
      @volume_size = resource[:volume_size]
      @ensure = resource[:ensure]
      @url  = resource[:device_url]  
        
      Puppet.debug "volume_name :" + @volume_name
      Puppet.debug "volume_size :" + @volume_size
      Puppet.debug "ensure :" + @ensure.to_s
      Puppet.debug "url :" + @url.to_s

      #Check volume existence  
      isExists =  isVolumeExists(@volume_name,@volume_size)
      Puppet.info("\n Is volume:'"+@volume_name+"' exists? "+ isExists.to_s)
      
      #Decide which operation to do Create\Update\Delete 
      if(@ensure == :present)
        if(isExists)
          @operation= self.class::UPDATE #"update"
          isExists = false  
        else
          @operation= self.class::CREATE #"create"
        end  
      elsif(@ensure == :absent)
        @operation= self.class::DELETE #"delete"
      end
      
      Puppet.debug("<<<<<<<<<< Operation to perform? "+ @operation)    
      return isExists
    end
end


