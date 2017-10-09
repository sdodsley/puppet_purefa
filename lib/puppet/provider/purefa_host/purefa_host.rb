require 'net/http'
require 'puppet/purestorage'

Puppet::Type.type(:purefa_host).provide(:purefa_host) do
    desc "Provider for Pure Storage purefa_host."

    def create
       Puppet.debug("<<<<<<<<<< Inside purefa_host create & operation:"+@operation)	
      executeHostRestApi(@operation,@host_name,@host_iqnlist)	
    end

    def destroy
       Puppet.debug("<<<<<<<<<< Inside purefa_host destroy & operation:"+@operation)
      executeHostRestApi(@operation,@host_name,@host_iqnlist)	
    end

    def exists?
       Puppet.debug("<<<<<<<<<< Inside purefa_host exists?")
      	@host_name =  resource[:host_name]
      	@host_iqnlist = resource[:host_iqnlist]
      	@ensure = resource[:ensure]
      	@url  = resource[:device_url]
      	@host_wwnlist = resource[:host_wwnlist]

       	Puppet.debug "host_name :" + @host_name
        Puppet.debug "host_iqnlist :" + @host_iqnlist.to_s
        Puppet.debug "ensure :" + @ensure.to_s
        Puppet.debug "host_wwnlist :" + @host_wwnlist.to_s
        Puppet.debug "url :" + @url.to_s

        #Check host existence  
        isExists =  isHostExists(@host_name,@host_iqnlist)
        
       Puppet.info("\n Is host: '"+@host_name+"' exists? "+ isExists.to_s)
      
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


