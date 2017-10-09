
Puppet::Type.newtype(:purefa_volume) do
    @doc = %q{

    }

    ensurable

    newparam(:name) do
        desc "The name of the volume."
    end

    newproperty(:size) do
        desc "The size of the volume."
    end

    newproperty(:purity_host) do
        desc "IP or FQDN for the virtual management address of the target FlashArray."
    end

    newparam(:api_token) do
        desc "API token used to authenticate with the FlashArray."
    end
end