# frozen_string_literal: true

RSpec.describe GoogleOneTapAuthenticator do
  subject(:authenticator) { described_class.new }

  it "requires a client ID and the login toggle" do
    expect(SiteSetting.google_one_tap_enabled).to eq(false)
    expect(authenticator.enabled?).to eq(false)

    SiteSetting.google_oauth2_client_id = "client_id"
    SiteSetting.google_one_tap_enabled = true
    expect(authenticator.enabled?).to eq(true)

    SiteSetting.google_oauth2_client_id = ""
    expect(authenticator.enabled?).to eq(false)
  end

  it "rejects enabling login without a client ID" do
    SiteSetting.google_one_tap_enabled = false

    expect { SiteSetting.google_one_tap_enabled = true }.to raise_error(
      Discourse::InvalidParameters,
    )
  end
end
