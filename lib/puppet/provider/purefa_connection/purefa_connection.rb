require 'net/http'
require 'puppet/purestorage'


Puppet::Type.type(:purefa_connection).provide(:purefa_connection) do
    desc "This is a provider for creating private connection between host and volume."

    def create
       Puppet.debug("<<<<<<<<<< Inside purefa_connection create")	
      executeConnectionRestApi(self.class::CREATE,@host_name,@volume_name)	
    end

    def destroy
       Puppet.debug("<<<<<<<<<< Inside purefa_connection destroy")
      executeConnectionRestApi(self.class::DELETE,@host_name,@volume_name)	
    end

    def exists?
       Puppet.debug("<<<<<<<<<< Inside purefa_connection exists?")
       @host_name =  resource[:host_name]
       @volume_name =  resource[:volume_name]
       @url  = resource[:device_url] 
         
       Puppet.debug("host_name :" + @host_name)
       Puppet.debug("volume_name :" + @volume_name)
       Puppet.debug("url :" + @url.to_s)
        
       #Check connection existence     
       isExists =  isConnectionExists(@host_name,@volume_name)
       
       Puppet.info("\n Is connection between host :'"+@host_name+"' and volume: '"+ @volume_name +"' exists? "+ isExists.to_s)
      return isExists
    end
end


