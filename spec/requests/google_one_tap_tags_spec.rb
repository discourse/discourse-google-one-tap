# frozen_string_literal: true

require "rails_helper"

describe "Google One Tap div and script tags" do
  before { SiteSetting.has_login_hint = false }

  fab!(:user) { Fabricate(:user) }

  context "when the plugin is enabled" do
    before { SiteSetting.google_one_tap_enabled = true }

    it "the tags are rendered when there is no logged-in user" do
      get "/"
      expect(response.status).to eq(200)
      expect(response.body).to include('<div id="g_id_onload"')
      expect(response.body).to include("<script src='https://accounts.google.com/gsi/client'")
    end

    it "the tags are not rendered when there is a logged-in user" do
      sign_in(user)
      get "/"
      expect(response.status).to eq(200)
      expect(response.body).not_to include('<div id="g_id_onload"')
      expect(response.body).not_to include("<script src='https://accounts.google.com/gsi/client'")
    end
  end

  context "when the plugin is disabled" do
    before { SiteSetting.google_one_tap_enabled = false }

    it "the tags are not rendered when there is no logged-in user" do
      get "/"
      expect(response.status).to eq(200)
      expect(response.body).not_to include('<div id="g_id_onload"')
      expect(response.body).not_to include("<script src='https://accounts.google.com/gsi/client'")
    end

    it "the tags are not rendered when there is a logged-in user" do
      sign_in(user)
      get "/"
      expect(response.status).to eq(200)
      expect(response.body).not_to include('<div id="g_id_onload"')
      expect(response.body).not_to include("<script src='https://accounts.google.com/gsi/client'")
    end
  end
end
