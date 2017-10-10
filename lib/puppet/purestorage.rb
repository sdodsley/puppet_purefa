#=====================================
# This class is mainly used for
# REST API 1.6 for Pure Storage Array
# It will have utility methods
# to perform CRUD operations on
# Volume and Host and creating
# connection between them.
#
# Supports REST API 1.6
#=====================================

require 'net/https'
require 'uri'
require 'json'

class FlashArray
  CREATE = 'create'.freeze
  UPDATE = 'update'.freeze
  DELETE = 'delete'.freeze
  LIST = 'list'.freeze

  attr_accessor :url

  def initialize(host, api_token)
    log('initializing FlashArray with host: #{host} and api_token: #{api_token}')
    @api_token = api_token
    @base_url = 'https://#{host}/api/1.6'
    @session_cookie = nil
    log('#{@base_url}')
    start_session
  end

  #----------------------------------------------------------------------------
  # Create session by passing api_token
  # This method returns session key which will be used in further rest calls
  #----------------------------------------------------------------------------
  def start_session
    log('#{self.class}.start_session')
    response = post_rest_call('/auth/session', { 'api_token' => @api_token }, false)
    log('response = #{response}')
    @session_cookie = response['set-cookie'].split('; ')[0]
  end

  def log(_str)
    Puppet.debug('#{self.class} #{_str}')
  end

  def send_request(req, uri, allow_retry = true)
    log('send_request: #{req.method} host=#{uri.host} path=#{uri.path} query=#{uri.query} allow_retry=#{allow_retry}')
    if @session_cookie
      req['Cookie'] = @session_cookie
    end
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |https|
      res = https.request(req)
      log('#{res.code} #{res.message}')
      if res.code == 401 && allow_retry == true
        @session_cookie = nil
        start_session
        res = send_request(req, false)
      end
      return res
    end
  end

  #-------------------------------------------------
  # Generic method for GET requests
  #-------------------------------------------------

  def get_rest_call(path)
    uri = URI.parse('#{@base_url}#{path}')
    request = Net::HTTP::Get.new(uri.path)
    return JSON.parse(send_request(request, uri).body)
  end

  #-------------------------------------------------
  # Generic method for POST requests
  #-------------------------------------------------

  def post_rest_call(path, body, parse = true)
    log('#{self.class}.post #{path} #{body}')
    uri = URI.parse('#{@base_url}#{path}')
    request = Net::HTTP::Post.new(uri.path)
    request.body = JSON.generate(body)
    request.content_type = 'application/json'
    response = send_request(request, uri)
    if parse
      return JSON.parse(response.body)
    else
      return response
    end
  end

  #-------------------------------------------------
  # Generic method for PUT requests
  #-------------------------------------------------

  def put_rest_call(path, body)
    uri = URI.parse('#{@base_url}#{path}')
    request = Net::HTTP::Put.new(uri.path)
    request.body = JSON.generate(body)
    request.content_type = 'application/json'
    return JSON.parse(send_request(request, uri).body)
  end

  #-------------------------------------------------
  # Generic method for DELETE requests
  #-------------------------------------------------

  def delete_rest_call(path, params = nil)
    uri = URI.parse('#{@base_url}#{path}')
    req_path = uri.path
    if params
      uri.query = URI.encode_www_form(params)
      req_path = '#{uri.path}?#{uri.query}'
    end
    request = Net::HTTP::Delete.new(req_path)
    return JSON.parse(send_request(request, uri).body)
  end

  #----------------------------------------------------
  # This method checks if volume with given name exists
  #  It is dedicated to volumes
  #-----------------------------------------------

  def is_volume_exists(arg_volume_name, arg_volume_size)
    url = '/volume/' + arg_volume_name
    output = get_rest_call(url)

    if output['pure_err_key'].nil?
      return true
    else
      return false
    end
  end

  #-------------------------------------------------
  # Its a controller method which decides
  # which rest api to call depending on key
  # It is dedicated to volumes
  #
  # arg[0] = volume_name, arg[1] = volume_size
  #-----------------------------------------------

  def execute_volume_rest_api(arg_key, *arg)
    Puppet.info(arg_key + ' Action for volume:' + arg[0])
    case arg_key
    when LIST then
      get_rest_call('/volume')
    when CREATE then
      url = '/volume/' + arg[0]
      body = Hash.new('size' => arg[1])
      post_rest_call(url, body['size'])
    when UPDATE then
      url = '/volume/' + arg[0]
      body = Hash.new('size' => arg[1])
      put_rest_call(url, body['size'])
    when DELETE then
      url = '/volume/' + arg[0]
      delete_rest_call(url)
    else
      Puppet.err('Invalid Operation:' + arg_key + ', Available operations are [create,update,delete,list].')
    end
  end

  #----------------------------------------------------
  # This method checks if a host with given name
  # already exists
  #-----------------------------------------------

  def is_host_exists(arg_host_name)
    url = '/host/' + arg_host_name
    output = get_rest_call(url)

    if output['pure_err_key'].nil?
      return true
    else
      return false
    end
  end

  #-------------------------------------------------
  # Its a controller method which decides
  # which rest api to call depending on key
  # It is dedicated to Hosts
  #
  # arg[0] = volume_name, arg[1] = volume_size
  #-----------------------------------------------

  def execute_host_rest_api(arg_key, *arg)
    Puppet.info(arg_key + ' Action for host:' + arg[0])
    case arg_key
    when LIST then
      get_rest_call('/host')
    when CREATE then
      url = '/host/' + arg[0]
      body = Hash.new('iqnlist' => arg[1])
      post_rest_call(url, body['iqnlist'])
    when UPDATE then
      url = '/host/' + arg[0]
      body = Hash.new('iqnlist' => arg[1])
      put_rest_call(url, body['iqnlist'])
    when DELETE then
      url = '/host/' + arg[0]
      delete_rest_call(url)
    else
      Puppet.err('Invalid Option:' + arg_key)
    end
  end

  #----------------------------------------------------
  # This method checks if connection with given name exists
  # It is dedicated to volumes
  # -----------------------------------------------

  def is_connection_exists(arg_host_name, arg_volume_name)
    url = '/host/' + arg_host_name + '/volume/' + arg_volume_name
    output = get_rest_call(url)

    if !output['vol'].nil?
      return true
    else
      return false
    end
  end

  #-------------------------------------------------
  # Its a controller method which decides
  # which rest api to call depending on key
  # It is dedicated to Hosts
  #
  # arg[0] = hostname, arg[1] = volumename
  #-----------------------------------------------

  def execute_connection_rest_api(arg_key, *arg)
    Puppet.info(arg_key + ' Action for connection between host :' + arg[0] + ' and volume:' + arg[1])
    case arg_key
    when CREATE then
      url = '/host/' + arg[0] + '/volume/' + arg[1]
      post_rest_call(url, '')
    when DELETE then
      url = '/host/' + arg[0] + '/volume/' + arg[1]
      delete_rest_call(url)
    else
      Puppet.err('Invalid Option:' + arg_key)
    end
  end
end
