
Puppet::Type.newtype(:purefa_host) do
    @doc = %q{
	  
    }
      
    ensurable
      
    newparam(:host_name) do 
        desc "The name of the host."
    end
      
    newparam(:host_iqnlist) do
   	    desc "The iqnlist"
    end
  
    newparam(:host_wwnlist) do
   	    desc "The wwnlist"
    end
  
    newproperty(:purity_host) do
        desc "IP or FQDN for the virtual management address of the target FlashArray."
    end

    newparam(:api_token) do
        desc "API token used to authenticate with the FlashArray."
    end
 end
