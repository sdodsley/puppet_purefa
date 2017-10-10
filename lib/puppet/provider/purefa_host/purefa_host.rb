require 'net/http'
require 'puppet/purestorage'

Puppet::Type.type(:purefa_host).provide(:purefa_host) do
  desc 'Provider for Pure Storage purefa_host.'

  def create
    Puppet.debug('<<<<<<<<<< Inside purefa_host create & operation:' + @operation)
    execute_host_rest_api(@operation, @host_name, @host_iqnlist)
  end

  def destroy
    Puppet.debug('<<<<<<<<<< Inside purefa_host destroy & operation:' + @operation)
    execute_host_rest_api(@operation, @host_name, @host_iqnlist)
  end

  def exists?
    Puppet.debug('<<<<<<<<<< Inside purefa_host exists?')
    @host_name = resource[:host_name]
    @host_iqnlist = resource[:host_iqnlist]
    @ensure = resource[:ensure]
    @url = resource[:device_url]
    @host_wwnlist = resource[:host_wwnlist]

    Puppet.debug 'host_name :' + @host_name
    Puppet.debug 'host_iqnlist :' + @host_iqnlist.to_s
    Puppet.debug 'ensure :' + @ensure.to_s
    Puppet.debug 'host_wwnlist :' + @host_wwnlist.to_s
    Puppet.debug 'url :' + @url.to_s

    # Check host existence
    is_exists = is_host_exists(@host_name)

    Puppet.info('\n Is host: ' + @host_name + ' exists? ' + isExists.to_s)

    # Decide which operation to do Create\Update\Delete
    if @ensure == :present
      if is_exists
        @operation = self.class::UPDATE
        is_exists = false
      else
        @operation = self.class::CREATE
      end
    elsif @ensure == :absent
      @operation = self.class::DELETE
    end

    Puppet.debug('<<<<<<<<<< Operation to perform? ' + @operation)
    return is_exists
  end
end
