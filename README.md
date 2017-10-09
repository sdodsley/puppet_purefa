## Pure Storage FlashArray Puppet Module

#### Table of Contents

  1. [Disclaimer](#disclaimer)
  2. [Overview](#overview)
  3. [Description](#description)
  4. [Setup](#setup)
    * [Connecting to a Pure Storage FlashArray](#connecting-to-a-purestorage-array)
  5. [Usage](#usage)
    * [Puppet Device](#puppet-device)
    * [Puppet Agent](#puppet-agent)
    * [Puppet Apply](#puppet-apply)
  6. [Supported use-cases](#supported-use-cases)  
  7. [Limitations](#limitations)
  8. [Development](#development)

## Disclaimer

This provider is written as best effort and provides no warranty expressed or
implied. Please contact the author(s) via [Pure Storage Support Team](https://www.purestorage.com/support.html) if you have
questions about this module before running or modifying.

## Overview

The Pure Storage FlashArray provider allows you to provision volumes on a 
Pure Storage FlashArray from either a puppet client or a puppet device proxy
host.

## Description

Using the `volume`, `host` and `connection` types, you
can quickly provision remote storage and attach it via iSCSI or FC from a
Pure Storage FlasArray to a client.

The provider utilizes the robust RestAPI available in the Pure Storage
FlashArray to remotely provision the necessary resources.

## Setup

### Connecting to a Pure Storage FlashArray

A connection to a Pure Storage FlashArray is made through the arrays
management IP address or FQDN name and an API token obtained from the
FlashArray GUI.
The connection information is supplied to the provider using one of the following
methods:

  1. A Facter-supplied URL.
  2. A user-supplied URL (in `device.conf` or `site.pp` file - examples provided here).

## Usage

### Puppet Device

The Puppet Network Device system is a way to configure devices' (switches,
routers, storage) which do not have the ability to run a puppet agent on
the devices. The device application acts as a smart proxy between the Puppet
Master and the managed device. To do this, puppet device will
sequentially connects to the master on behalf of the managed device
and will ask for a catalog (a catalog containing only the device
resources). It will then apply this catalog to the said device by translating
the resources to orders the managed device understands. Puppet device will
then report back to the master for any changes and failures as a standard node.

The Pure Storage FlashArray providers are designed to work with the puppet device
concept and in this case will retrieve their connection information from the `url`
and `api_token` given in Puppet's `device.conf` file. An example is shown below:

     [array1.puretec.purestorage.com]
      type purefa
      url puretec.purestorage.com
	  api_token osjojerog-wfoir-wew-wfrregre-wfergr

when using the Puppet Device connection to the FlashArray is accessed from the machine
running 'device' only.

command : `puppet device`

### Puppet Agent

Puppet agent is the client/slave side of the puppet master/slave relationship.
In the case of puppet agent the connection information needs to be included in
the manifest supplied to the agent from the master or it could be included
in a custom fact passed to the client. The connection string must be supplied
as a URL. See the example manifests (`complete_create.pp`) for details.

When using Puppet Agent, connections to the Pure Storage FlashArray will be
initiated from every machine which calls the Pure Storage puppet module.

Command: `puppet agent -t`

### Puppet Apply

Puppet apply is the client only application of a local manifest. Puppet apply
is supported in the same way as puppet agent by the Pure Storage providers. 
The connection string must be supplied as a URL and API Token. See the example 
manifests (`complete_create.pp`) for details.

Command: `puppet apply <manifest_file_path>`
   e.g. `puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp`

## Supported use-cases:

   1. create \ update \ delete volume
      * Array of iqn-list supported
        - eg.  host_iqnlist =>  ["iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e03j","iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e03k"],
      * volume size cannot be reduced due to a RestAPI constraint.
   2. create \ update \ delete host
   3. create \ delete connection

## Limitations

Today the Pure Storage FlashArray puppet module supports create, update and delete of 
volumes, hosts and attachment between the two. 
Currently it only supports iSCSI connections and IQN ids.

## Development

Please see the [Pure Storage OpenConnect GitHub](https://github.com/PureStorage-OpenConnect/purestorage-puppet) for any issues,
discussion, advice or contribution(s).

To get started with developing this module, you'll need a functioning Ruby installation.