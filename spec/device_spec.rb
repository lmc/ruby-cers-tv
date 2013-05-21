require 'spec_helper'

describe RubyCersTv::Device do

  let(:device) { RubyCersTv::Device.new("100.32.100.32","c0-01-fa-ce-d0-0d") }

  describe "#register" do
    it "should send registration request" do
      device.should_receive(:write_http_request).with(http_request_match(<<-HTTP_REQ),true)
        GET /cers/api/register?name=My%20Rad%20Device&registrationType=new&deviceId=MediaRemote%3A11-22-33-44-55-66 HTTP/1.1
        Host: 100.32.100.32:80
        User-Agent: MediaRemote/3.0.1 CFNetwork/548.0.4 Darwin/11.0.0
        X-CERS-DEVICE-INFO: iPhone OS5.0.1/3.0.1/iPhone3,3
        X-CERS-DEVICE-ID: MediaRemote:11-22-33-44-55-66
        Connection: close

      HTTP_REQ
      device.register("11-22-33-44-55-66","My Rad Device")
    end
  end

  describe "#get_remote_command_list" do
    it "should send get_remote_command_list request" do
      device.should_receive(:write_http_request).with(http_request_match(<<-HTTP_REQ),true).and_return(mock_command_list)
        GET /cers/api/getRemoteCommandList HTTP/1.1
        Host: 100.32.100.32:80
        User-Agent: MediaRemote/3.0.1 CFNetwork/548.0.4 Darwin/11.0.0
        X-CERS-DEVICE-INFO: iPhone OS5.0.1/3.0.1/iPhone3,3
        X-CERS-DEVICE-ID: MediaRemote:c0-01-fa-ce-d0-0d
        Connection: close

      HTTP_REQ
      device.get_remote_command_list.should == [{"name"=>"Confirm", "type"=>"ircc", "value"=>"AAAAAQAAAAEAAABlAw=="}]
    end
  end

  describe "#send_ircc" do
    it "should send send_ircc request" do
      device.should_receive(:write_http_request).with(http_request_match(<<-HTTP_REQ),false)
        POST /IRCC HTTP/1.1
        Host: 100.32.100.32:80
        User-Agent: MediaRemote/3.0.1 CFNetwork/548.0.4 Darwin/11.0.0
        X-CERS-DEVICE-INFO: iPhone OS5.0.1/3.0.1/iPhone3,3
        X-CERS-DEVICE-ID: MediaRemote:c0-01-fa-ce-d0-0d
        SOAPAction: \"urn:schemas-sony-com:service:IRCC:1#X_SendIRCC\"
        Content-Type: text/xml; charset=utf-8
        Content-Length: 325

        <?xml version=\"1.0\"?>
        <s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
          <s:Body>
            <u:X_SendIRCC xmlns:u=\"urn:schemas-sony-com:service:IRCC:1\">
              <IRCCCode>AAAAAQAAAAEAAABgAw==</IRCCCode>
            </u:X_SendIRCC>
          </s:Body>
        </s:Envelope>
      HTTP_REQ
      device.send_ircc("AAAAAQAAAAEAAABgAw==")
    end
  end

  describe "#send_ircc_mdf" do
    it "should convert manufacturer/device/function values into ircc" do
      device.should_receive(:send_ircc).with("AAAAAgAAABoAAABaAw==")
      device.send_ircc_mdf(2, 26, 90)
    end
  end

  protected

  def http_request_match(req)
    spaces = 8
    req.gsub(/\n/,"\r\n").gsub(/^[\t ]{#{spaces}}/,'')
  end

  def mock_command_list
    <<-XML
    <?xml version="1.0"?>
    <remoteCommandList>
        <command name="Confirm" type="ircc" value="AAAAAQAAAAEAAABlAw==" />
    </remoteCommandList>
    XML
  end

end
