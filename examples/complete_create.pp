#Example of Puppet Device
node '10.234.112.100' { #--> This is Device name
  purefa_volume{ 'pure_storage_volume':
                #ensure either 'present' or 'absent'
                ensure      => 'present',
                volume_name => 'test_device_volume',
                volume_size => '2.0G',
  }
  purefa_host{ 'pure_storage_host':
                ensure       => 'present',
                host_name    => 'test-device-host',
                host_iqnlist => ['iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e03f','iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e03g'],
  }
  purefa_connection{ 'pure_storage_connection':
                ensure      => 'present',
                host_name   => 'test-device-host',
                volume_name => 'test_device_volume',
                #Added dependency on volume and host resource types
                #to be present, other wise connection will fail.		
                require     => [Volume['pure_storage_volume'],
                  Hostconfig['pure_storage_host']
                  ],
  }

}
#Example of Puppet Agent
node 'puppet-agent.nyc.purestorage.com'{ #--> This is Agent vm name
    #Note : device_url and api_token are MANDATORY here.	
  $device_url = '10.234.112.100'
  $api_token = "dsfpokf-fofjojrf-fwojrogjger-g-ewfrfr"
  
  purefa_volume{ 'pure_storage_volume':
                #ensure either 'present' or 'absent'
                ensure      => 'present',
                volume_name => 'test_agent_volume',
                volume_size => '1.0G',
                device_url  => $device_url,
  }
  purefa_host{{ 'pure_storage_host':
                ensure       => 'present',
                host_name    => 'test-agent-host',
                host_iqnlist => ['iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e03h','iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e0i'],
                device_url   => $device_url,
  }
  purefa_connection{{ 'pure_storage_connection':
                ensure      => 'present',
                host_name   => 'test-agent-host',
                volume_name => 'test_agent_volume',
                #Added dependency on volume and host resource types
                #to be present, other wise connection will fail.
                require     => [Volume['pure_storage_volume'],
                  Hostconfig['pure_storage_host']
                  ],
                device_url  => $device_url,
  }
}
#Example of Puppet Apply
node 'puppet.nyc.purestorage.com'{ #--> This is master vm name
    #Note : device_url and api_token are MANDATORY here.	
  $device_url = '10.234.112.100'
  $api_token = "dsfpokf-fofjojrf-fwojrogjger-g-ewfrfr"

  volume{ 'pure_storage_volume':
                #ensure either 'present' or 'absent'
                ensure      => 'present',
                volume_name => 'test_apply_volume',
                volume_size => '1.0G',
                device_url  => $device_url,
  }
  hostconfig{ 'pure_storage_host':
                ensure       => 'present',
                host_name    => 'test-apply-host',
                host_iqnlist => ['iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e03j','iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e03k'],
                device_url   => $device_url,
  }
  connection{ 'pure_storage_connection':
                ensure      => 'present',
                host_name   => 'test-apply-host',
                volume_name => 'test_apply_volume',
                #Added dependency on volume and host resource types
                #to be present, other wise connection will fail.
                require     => [Volume['pure_storage_volume'],
                  Hostconfig['pure_storage_host']
                  ],
                device_url  => $device_url,
  }
}
