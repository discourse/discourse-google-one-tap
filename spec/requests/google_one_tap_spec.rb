# frozen_string_literal: true

describe "Google One Tap" do
  fab!(:user)

  let(:rsa_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:cert) do
    public_key = rsa_key.public_key

    cert_subject = "/C=BE/O=Test/OU=Test/CN=Test"

    cert = OpenSSL::X509::Certificate.new
    cert.subject = cert.issuer = OpenSSL::X509::Name.parse(cert_subject)
    cert.not_before = Time.now
    cert.not_after = Time.now + 365 * 24 * 60 * 60
    cert.public_key = public_key
    cert.serial = 0x0
    cert.version = 2

    cert.sign(rsa_key, OpenSSL::Digest.new("SHA256"))

    cert
  end

  before do
    SiteSetting.google_one_tap_enabled = true
    SiteSetting.google_oauth2_client_id = "goooogleclientid"
    stub_request(:get, "https://www.googleapis.com/oauth2/v1/certs").to_return(
      status: 200,
      body: JSON.generate(cert001: cert.to_pem),
    )
  end

  def build_jwt_token(key = rsa_key, **overrides)
    payload = {
      iss: "https://accounts.google.com",
      nbf: 1_665_718_013,
      aud: SiteSetting.google_oauth2_client_id,
      sub: "89273448478923324",
      email: "somebodyoncetoldme@gmail.com",
      email_verified: true,
      azp: SiteSetting.google_oauth2_client_id,
      name: "Osama Shrek",
      picture: "https://lh3.googleusercontent.com/a/somepicturepath",
      given_name: "Osama",
      family_name: "Shrek",
      iat: Time.zone.now.to_i,
      exp: Time.zone.now.to_i + 3600,
      jti: SecureRandom.hex,
      cid: SiteSetting.google_oauth2_client_id,
    }.merge(overrides)
    JWT.encode(payload, key, "RS256")
  end

  it "fails CSRF if the g_csrf_token cookie is missing" do
    post "/auth/google_one_tap/callback",
         params: {
           g_csrf_token: "abcdefg",
           credential: build_jwt_token,
         }
    expect(response.status).to eq(302)
    expect(cookies[:authentication_data]).to be_blank
    expect(cookies[:_t]).to be_blank
    expect(response.location).to eq(
      "/auth/failure?message=invalid_csrf_token&strategy=google_one_tap",
    )
  end

  it "fails CSRF if the g_csrf_token param is missing" do
    post "/auth/google_one_tap/callback",
         params: {
           credential: build_jwt_token,
         },
         headers: {
           "HTTP_COOKIE" => "g_csrf_token=abcdefg",
         }
    expect(response.status).to eq(302)
    expect(cookies[:authentication_data]).to be_blank
    expect(cookies[:_t]).to be_blank
    expect(response.location).to eq(
      "/auth/failure?message=invalid_csrf_token&strategy=google_one_tap",
    )
  end

  it "fails CSRF if the g_csrf_token param and cookie are missing" do
    post "/auth/google_one_tap/callback", params: { credential: build_jwt_token }
    expect(response.status).to eq(302)
    expect(cookies[:authentication_data]).to be_blank
    expect(cookies[:_t]).to be_blank
    expect(response.location).to eq(
      "/auth/failure?message=invalid_csrf_token&strategy=google_one_tap",
    )
  end

  it "fails if the Google client ID in the JWT doesn't match the one configured in the site setting" do
    credential = build_jwt_token
    SiteSetting.google_oauth2_client_id = "brandnewclientid"
    post "/auth/google_one_tap/callback",
         params: {
           g_csrf_token: "abcdefg",
           credential: credential,
         },
         headers: {
           "HTTP_COOKIE" => "g_csrf_token=abcdefg",
         }
    expect(response.status).to eq(302)
    expect(cookies[:authentication_data]).to be_blank
    expect(cookies[:_t]).to be_blank
    expect(response.location).to eq(
      "/auth/failure?message=invalid_credentials&strategy=google_one_tap",
    )
  end

  it "fails if the JWT is expired" do
    post "/auth/google_one_tap/callback",
         params: {
           g_csrf_token: "abcdefg",
           credential: build_jwt_token(iat: 3.hours.ago.to_i, exp: 2.hours.ago.to_i),
         },
         headers: {
           "HTTP_COOKIE" => "g_csrf_token=abcdefg",
         }
    expect(response.status).to eq(302)
    expect(cookies[:authentication_data]).to be_blank
    expect(cookies[:_t]).to be_blank
    expect(response.location).to eq(
      "/auth/failure?message=invalid_credentials&strategy=google_one_tap",
    )
  end

  it "fails if the JWT is signed with a non-Google key" do
    post "/auth/google_one_tap/callback",
         params: {
           g_csrf_token: "abcdefg",
           credential: build_jwt_token(OpenSSL::PKey::RSA.new(2048)),
         },
         headers: {
           "HTTP_COOKIE" => "g_csrf_token=abcdefg",
         }
    expect(response.status).to eq(302)
    expect(cookies[:authentication_data]).to be_blank
    expect(cookies[:_t]).to be_blank
    expect(response.location).to eq(
      "/auth/failure?message=invalid_credentials&strategy=google_one_tap",
    )
  end

  it "fails if the JWT issuer isn't Google" do
    post "/auth/google_one_tap/callback",
         params: {
           g_csrf_token: "abcdefg",
           credential: build_jwt_token(iss: "accounts.gooogle.com"),
         },
         headers: {
           "HTTP_COOKIE" => "g_csrf_token=abcdefg",
         }
    expect(response.status).to eq(302)
    expect(cookies[:authentication_data]).to be_blank
    expect(cookies[:_t]).to be_blank
    expect(response.location).to eq(
      "/auth/failure?message=invalid_credentials&strategy=google_one_tap",
    )
  end

  it "redirects to the homepage and sets authentication_data cookie when it's successful" do
    post "/auth/google_one_tap/callback",
         params: {
           g_csrf_token: "abcdefg",
           credential: build_jwt_token,
         },
         headers: {
           "HTTP_COOKIE" => "g_csrf_token=abcdefg",
         }
    expect(response.status).to eq(302)
    expect(response.location).to eq("http://test.localhost/")
    expect(cookies[:_t]).to be_blank
    expect(JSON.parse(cookies[:authentication_data]).symbolize_keys).to eq(
      auth_provider: "google_one_tap",
      can_edit_name: true,
      can_edit_username: true,
      destination_url: "/",
      email: "somebodyoncetoldme@gmail.com",
      email_valid: true,
      name: "Osama Shrek",
      username: "Osama_Shrek",
    )
  end

  it "logs in the user if the email in the JWT is already linked to a user" do
    post "/auth/google_one_tap/callback",
         params: {
           g_csrf_token: "abcdefg",
           credential: build_jwt_token(email: user.email),
         },
         headers: {
           "HTTP_COOKIE" => "g_csrf_token=abcdefg",
         }
    expect(response.status).to eq(302)
    expect(response.location).to eq("http://test.localhost/")
    expect(cookies[:_t]).to be_present
  end
end
