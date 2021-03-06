
Puppet::Type.newtype(:purefa_connection) do
  @doc = ''

  validate do
    raise('host name and volume name are mandatory') if !self[:host_name] || !self[:volume_name]
  end

  ensurable

  newparam(:host_name) do
    desc 'The name of the host.'
    isnamevar
    validate do |value|
      raise('host name: #{value} can not be empty or null') if value == 'null' || value.strip.empty?
    end
  end

  newparam(:volume_name) do
    desc 'The name of the volume.'
    validate do |value|
      raise('volume name: #{value} can not be empty or null') if value == 'null' || value.strip.empty?
    end
  end

  newproperty(:purity_host) do
    desc 'IP or FQDN for the virtual management address of the target FlashArray.'
  end

  newparam(:api_token) do
    desc 'API token used to authenticate with the FlashArray.'
  end
end
