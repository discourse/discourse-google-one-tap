# frozen_string_literal: true

require_relative '../../../lib/google_one_tap'

describe OmniAuth::Strategies::GoogleOneTap do
  let(:app) do
    @app_called = false
    lambda do |*args|
      @app_called = true
      [200, {}, ['Hello.']]
    end
  end

  subject do
    OmniAuth::Strategies::GoogleOneTap.new(app, provider: 'google_one_tap')
  end
  before do
    OmniAuth.config.test_mode = true
  end
    describe 'callback phase with wrong csrf' do
      before do
        subject.stubs(:request).returns(mock('object'))
        subject.request.stubs(:params).returns("g_csrf_token" => "something")
        subject.request.stubs(:cookies).returns("g_csrf_token" => "somehtingelse")
      end
      it 'should fail because of csrf' do
        expect { subject.check_csrf }.to raise_error(OmniAuth::Strategies::GoogleOneTap::GoogleOneTapCSFRError, /Invlaid CSRF/)
        expect(@app_called).to eq(false)
      end
    end
   describe 'callback phase with wrong wrong credential' do
     before do
       WebMock.disable_net_connect!(allow: ["https://www.googleapis.com"])
       subject.stubs(:request).returns(mock('object'))
      subject.request.stubs(:params).returns("g_csrf_token" => "correct_csrf", "credential" => "wrong_credential")
      subject.request.stubs(:cookies).returns("g_csrf_token" => "correct_csrf")
     end
      it 'should fail because of wrong credential' do
        expect { subject.build_access_token }.to raise_error(OmniAuth::Strategies::GoogleOneTap::GoogleOneTapValidationError, /Validation Error/)
        expect(@app_called).to eq(false)
      end
   end

   describe 'callback phase when it cannot reach Google server to fetch certs' do
     before do
       stub_request(:get, "https://www.googleapis.com/oauth2/v1/certs").to_return(status: 404)
       subject.stubs(:request).returns(mock('object'))
      subject.request.stubs(:params).returns("g_csrf_token" => "correct_csrf")
      subject.request.stubs(:cookies).returns("g_csrf_token" => "correct_csrf")
     end
      it 'should fail because it cannot reach Google server' do
        expect { subject.build_access_token }.to raise_error(GoogleIDToken::CertificateError, /Unable to retrieve Google public keys/)
        expect(@app_called).to eq(false)
      end
   end
    describe 'callback phase when it return correct credeintal' do
      let(:auth_hash) { last_request.env['omniauth.auth'] }
      before do
        SiteSetting.google_oauth2_client_id = "client_id_example"
        cert_result = generate_certificate
        cert2_result = generate_certificate
        stub_request(:get, "https://www.googleapis.com/oauth2/v1/certs").to_return(status: 200, body: { "123": cert_result[:cert].to_pem, "321": cert2_result[:cert].to_pem }.to_json)
        token = craete_token(cert_result[:key])
        subject.stubs(:request).returns(mock('object'))
        subject.request.stubs(:params).returns("g_csrf_token" => "correct_csrf", "credential" => token)
        subject.request.stubs(:cookies).returns("g_csrf_token" => "correct_csrf")
        subject.stubs(:env).returns({})
      end
      it 'should pass' do
        expect(subject.callback_phase[0]).to eq 200
      expect(subject.info[:name]).to eq("Ghassan Alkoumi")
      expect(@app_called).to eq(true)
      end
    end
    describe 'callback phase when credential aud does not match client_id' do
      before do
        SiteSetting.google_oauth2_client_id = "diffrernt_client_id"
        cert_result = generate_certificate
        cert2_result = generate_certificate
        subject.stubs(:request).returns(mock('object'))
        stub_request(:get, "https://www.googleapis.com/oauth2/v1/certs").to_return(status: 200, body: { "123": cert_result[:cert].to_pem, "321": cert2_result[:cert].to_pem }.to_json)
        token = craete_token(cert_result[:key])
        subject.request.stubs(:params).returns("g_csrf_token" => "correct_csrf", "credential" => token)
        subject.request.stubs(:cookies).returns("g_csrf_token" => "correct_csrf")
        subject.stubs(:env).returns({})
      end
      it 'should fail because of wrong client id' do
        expect { subject.build_access_token }.to raise_error(OmniAuth::Strategies::GoogleOneTap::GoogleOneTapValidationError, /Validation Error/)
        expect(@app_called).to eq(false)
      end
    end

   def craete_token(key)
     JWT.encode({
       "iss" => "https://accounts.google.com",
       "aud" => "client_id_example",
       "iat" => Time.now.to_i,
       "exp" => Time.now.to_i + 3600,
       "email" => "example@google.com",
       "email_verified" => true,
       "name" => "Ghassan Alkoumi",
       "given_name" => "Ghassan",
       "family_name" => "Alkoumi",
       "jti" => "1234567890",
       "sub" => "3434342459",
     }, key, 'RS256')
   end
   # The following function is replicated from google-id-token gem
   # Ref: https://github.com/google/google-id-token/blob/46ac65ff03bd125d93b5acadd1c1adbdb86d919c/spec/google-id-token_spec.rb#L183-L200
   def generate_certificate
     key = OpenSSL::PKey::RSA.new(2048)
    public_key = key.public_key

    cert_subject = "/C=BE/O=Test/OU=Test/CN=Test"

    cert = OpenSSL::X509::Certificate.new
    cert.subject = cert.issuer = OpenSSL::X509::Name.parse(cert_subject)
    cert.not_before = Time.now
    cert.not_after = Time.now + 365 * 24 * 60 * 60
    cert.public_key = public_key
    cert.serial = 0x0
    cert.version = 2

    cert.sign key, OpenSSL::Digest::SHA1.new

    { key: key, cert: cert }
  end
end
