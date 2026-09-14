# frozen_string_literal: true

require_relative "../../db/migrate/20260911083306_preserve_google_one_tap_enabled"

RSpec.describe PreserveGoogleOneTapEnabled do
  subject(:migration) { described_class.new }

  before do
    DB.exec("DELETE FROM site_settings WHERE name = 'google_one_tap_enabled'")
    Migration::Helpers.stubs(:existing_site?).returns(true)
  end

  it "preserves enabled login on existing sites and can run twice" do
    2.times { migration.up }

    expect(
      DB.query_single("SELECT value FROM site_settings WHERE name = 'google_one_tap_enabled'"),
    ).to eq(["t"])
  end

  it "preserves an explicit disabled value" do
    DB.exec(
      "INSERT INTO site_settings (name, data_type, value, created_at, updated_at) VALUES ('google_one_tap_enabled', #{described_class::BOOLEAN_TYPE}, 'f', NOW(), NOW())",
    )

    migration.up

    expect(
      DB.query_single("SELECT value FROM site_settings WHERE name = 'google_one_tap_enabled'"),
    ).to eq(["f"])
  end

  it "does not add settings on fresh installs" do
    Migration::Helpers.stubs(:existing_site?).returns(false)

    migration.up

    expect(
      DB.query_single("SELECT value FROM site_settings WHERE name = 'google_one_tap_enabled'"),
    ).to be_empty
  end
end
