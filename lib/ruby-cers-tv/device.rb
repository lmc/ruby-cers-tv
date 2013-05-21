require 'socket'
require 'rexml/document'
require 'base64'
require 'uri'

class RubyCersTv::Device

  def initialize(host,mac,logger = nil)
    @host = host
    @mac = mac
    @logger = logger
  end

  # big thanks to Michael Lampard and Michael Wendel who both indepedently got registration working
  def register(new_mac = nil,name = nil)
    new_mac ||= "c0-01-fa-ce-d0-0d"
    name ||= "ruby-cers-tv client"

    old_mac = @mac # TODO: refactor http_request so i don't have to do this awful thing
    begin
      @mac = new_mac
      args = {name: URI.escape(name), registrationType: :new, deviceId: "MediaRemote%3A#{new_mac}"}
      args = args.map { |a,v| "#{a}=#{v}" }.join("&")
      response = http_request("GET","/cers/api/register?#{args}",{"Connection" => "close"},"",true)
    ensure
      @mac = old_mac
    end
  end


  def hdmi_1
    send_ircc_mdf(2, 26, 90)
  end

  def hdmi_2
    send_ircc_mdf(2, 26, 91)
  end

  def hdmi_3
    send_ircc_mdf(2, 26, 92)
  end

  def hdmi_4
    send_ircc_mdf(2, 26, 93)
  end

  def volume_up
    send_ircc("AAAAAQAAAAEAAAASAw==")
  end

  def volume_down
    send_ircc("AAAAAQAAAAEAAAASAw==")
  end


  def get_remote_command_list
    response = http_request("GET","/cers/api/getRemoteCommandList",{"Connection" => "close"},"",true)
    log ">>>>>>"
    log "#{response}"
    log ">>>>>>"
    xml = REXML::Document.new(response)
    xml.elements.first.elements.map do |command|
      Hash[ command.attributes.to_hash.map{|k,v| [k,v]} ]
    end
  end

  def send_ircc_mdf(manu,device,function)
    payload = [0, 0, 0, manu, 0, 0, 0, device, 0, 0, 0, function, 3]
    encoded = Base64.encode64(payload.map{|i| i.chr}.join)[0...-1] #no trailing \n
    send_ircc(encoded)
  end

  def send_ircc(ircc = "AAAAAQAAAAEAAABgAw==")
    body = <<-HTTP_POST_BODY
<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <s:Body>
    <u:X_SendIRCC xmlns:u="urn:schemas-sony-com:service:IRCC:1">
      <IRCCCode>#{ircc}</IRCCCode>
    </u:X_SendIRCC>
  </s:Body>
</s:Envelope>
HTTP_POST_BODY
    body.gsub!(/\n/,"\r\n")
    http_request("POST","/IRCC",{
      'SOAPAction'     => '"urn:schemas-sony-com:service:IRCC:1#X_SendIRCC"',
      'Content-Type'   => 'text/xml; charset=utf-8',
      'Content-Length' => "#{body.bytesize}"
    },body,false)
  end


  protected


  def headers(custom_headers = {})
    {
      "Host"               => "#{@host}:80",
      "User-Agent"         => "MediaRemote/3.0.1 CFNetwork/548.0.4 Darwin/11.0.0",
      "X-CERS-DEVICE-INFO" => "iPhone OS5.0.1/3.0.1/iPhone3,3",
      "X-CERS-DEVICE-ID"   => "MediaRemote:#{@mac}"
    }.merge(custom_headers)
  end

  def http_request(method,path,custom_headers,body = nil,read_socket = true)
    header_str = headers(custom_headers).map{|k,v| "#{k}: #{v}" }.join("\r\n")
    req  = "#{method} #{path} HTTP/1.1\r\n#{header_str}\r\n\r\n"
    req += "#{body}" if body

    log "== CersDevice#send_request ===="
    log req
    log "== ===="

    write_http_request(req,read_socket)
  end

  def write_http_request(request_body,read_socket = true)
    socket = TCPSocket.new(@host,80)
    socket.write(request_body)
    begin
      if read_socket
        socket.read
      else
        true
      end
    ensure
      socket.close
    end
  end

  def log(text)
    @logger.debug(text) if @logger
  end

end
