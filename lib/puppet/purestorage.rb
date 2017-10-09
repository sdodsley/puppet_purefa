#=====================================
#This class  is  mainly used for
#REST API 1.6 for Pure Storage Array
#It will have utility methods
#to perform CRUD operations on
#Volume and Host and creating
#connection between them.
#
# Supports REST API 1.6
#=====================================

require 'net/https'
require 'uri'
require 'json'

class FlashArray

CREATE = "create"
UPDATE = "update"
DELETE = "delete"
LIST = "list"

attr_accessor :url

    def initialize(host, api_token)
        log("initializing FlashArray with host: #{host} and api_token: #{api_token}")
        @api_token = api_token
        @base_url = "https://#{host}/api/1.6"
        @session_cookie = nil
        log("#{@base_url}")
        start_session()
    end

#----------------------------------------------------------------------------
# Create session by passing api_token
# This method returns session key which will be used in further rest calls
#----------------------------------------------------------------------------
    def start_session()
        log("#{self.class}.start_session")
        response = postRestCall('/auth/session', {'api_token' => @api_token}, false)
        log("response = #{response}")
        @session_cookie = response['set-cookie'].split('; ')[0]
    end


    def getSession
        token = createToken()
        if(token==nil)
            raise "Unable to create a token for device: "+@deviceIp+". Please check the credentials or device Ip Address provided in the url!"
        else
            session = createSession(token)
        end

        return session
    end


    def log(str)
        Puppet.debug("#{self.class} #{str}")
    end


    def send_request(req, uri, allow_retry=true)
        log("send_request: #{req.method} host=#{uri.host} path=#{uri.path} query=#{uri.query} allow_retry=#{allow_retry}")
        if @session_cookie
            req['Cookie'] = @session_cookie
        end
        Net::HTTP.start(uri.host, uri.port, :use_ssl => true, :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
            res = https.request(req)
            log("#{res.code} #{res.message}")
            if res.code == 401 and allow_retry == true
                @session_cookie = nil
                start_session()
                res = send_request(req, false)
            end
            return res
        end
    end

#-------------------------------------------------
# Generic method for GET requests
#-------------------------------------------------

    def getRestCall(path)
        uri = URI.parse("#{@base_url}#{path}")
        request = Net::HTTP::Get.new(uri.path)
        return JSON.parse(send_request(request, uri).body)
    end

#-------------------------------------------------
# Generic method for POST requests
#-------------------------------------------------

    def postRestCall(path, body, parse=true)
        log("#{self.class}.post #{path} #{body}")
        uri = URI.parse("#{@base_url}#{path}")
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

    def putRestCall(path, body)
        uri = URI.parse("#{@base_url}#{path}")
        request = Net::HTTP::Put.new(uri.path)
        request.body = JSON.generate(body)
        request.content_type = 'application/json'
        return JSON.parse(send_request(request, uri).body)
    end

#-------------------------------------------------
# Generic method for DELETE requests
#-------------------------------------------------

    def deleteRestCall(path, params=nil)
        uri = URI.parse("#{@base_url}#{path}")
        req_path = uri.path
        if params
            uri.query = URI.encode_www_form(params)
            req_path = "#{uri.path}?#{uri.query}"
        end
        request = Net::HTTP::Delete.new(req_path)
        return JSON.parse(send_request(request, uri).body)
    end

#----------------------------------------------------
# This method checks if volume with given name exists
#  It is dedicated to volumes
#-----------------------------------------------

    def isVolumeExists(arg_volume_name, arg_volume_size)
        url = "/volume/"+arg_volume_name
        output = getRestCall(url)

        if(output["pure_err_key"]==nil)
            return true
        else
           return false
        end
    end

#-------------------------------------------------
# Its a controller method which decides
# which rest api to call depending on key
# It is dedicated to volumes
#-----------------------------------------------

    def executeVolumeRestApi(arg_key,*arg)
        Puppet.info(arg_key + " Action for volume:"+ arg[0])
        case arg_key
            when LIST  then
                getRestCall("/volume")
            when  CREATE then #arg[0] = volume_name, arg[1] = volume_size
                url = "/volume/"+arg[0]
                body = Hash.new("size" => arg[1])
                postRestCall(url,body["size"])
            when  UPDATE then
                url = "/volume/"+arg[0]
                body = Hash.new("size" => arg[1])
                putRestCall(url,body["size"])
            when  DELETE then
                url = "/volume/"+arg[0]
                deleteRestCall(url)
            else
                #puts "Invalid Option:" + arg_key
                Puppet.err("Invalid Operation:" + arg_key + ", Available operations are [create,update,delete,list].")
        end
    end

#----------------------------------------------------
# This method checks if a host with given name
# already exists
#-----------------------------------------------

    def isHostExists(arg_host_name, arg_host_iqnlist)
        url = "/host/"+arg_host_name
        output = getRestCall(url)

        if(output["pure_err_key"]==nil)
            return true
        else
            return false
        end
    end

#-------------------------------------------------
# Its a controller method which decides
# which rest api to call depending on key
# It is dedicated to Hosts
#-----------------------------------------------

    def executeHostRestApi(arg_key,*arg)
        Puppet.info(arg_key + " Action for host:"+ arg[0])
        case arg_key
            when LIST  then
                getRestCall("/host")
            when  CREATE then #arg[0] = volume_name, arg[1] = volume_size
                url = "/host/"+arg[0]
                body = Hash.new("iqnlist" => arg[1])
                postRestCall(url,body["iqnlist"])
            when  UPDATE then
                url = "/host/"+arg[0]
                body = Hash.new("iqnlist" => arg[1])
                putRestCall(url,body["iqnlist"])
            when  DELETE then
                url = "/host/"+arg[0]
                deleteRestCall(url)
            else
                Puppet.err("Invalid Option:" + arg_key)
         end      
    end 

#----------------------------------------------------
# This method checks if connection with given name exists
# It is dedicated to volumes
# -----------------------------------------------

    def isConnectionExists(arg_host_name, arg_volume_name)
        url = "/host/"+arg_host_name+"/volume"
        output = getRestCall(url)

        if(output["vol"]!=nil)
            return true
        else
            return false
        end
    end

#-------------------------------------------------
# Its a controller method which decides
# which rest api to call depending on key
# It is dedicated to Hosts
# arg[0] = hostname, arg[1] = volumename
#-----------------------------------------------

    def executeConnectionRestApi(arg_key,*arg)
        Puppet.info(arg_key + " Action for connection between host :"+arg[0]+" and volume:"+ arg[1])
        case arg_key
            when  CREATE then #arg[0] = volume_name, arg[1] = volume_size
                url = "/host/"+arg[0]+"/volume/"+arg[1]
                postRestCall(url,"")
            when  DELETE then
                url = "/host/"+arg[0]+"/volume/"+arg[1]
                deleteRestCall(url)
            else
                Puppet.err("Invalid Option:" + arg_key)
        end      
    end

end