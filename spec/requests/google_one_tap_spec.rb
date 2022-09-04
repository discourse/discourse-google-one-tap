# frozen_string_literal: true

require 'rails_helper'

describe "Tests for the application response when plugin enabled and user not logged in" do

  before do
    SiteSetting.google_one_tap_enabled = true
    SiteSetting.has_login_hint = false
  end
  it "It should incldue script and conatiner div when no user exits" do
    get "/"
    expect(response.status).to eq(200)
    expect(response.body).to include("<div id='g_id_onload'")
    expect(response.body).to include("<script src='https://accounts.google.com/gsi/client'")
  end

end

describe "Tests for the application response when plugin eabled and user logged in" do

  before do
    SiteSetting.google_one_tap_enabled = true
    SiteSetting.has_login_hint = false
    sign_in(Fabricate(:user, name: 'Jeff Atwood'))
  end

it "Should not incldue div container because user is already logged in" do
  get "/"
    expect(response.body).to_not include("<div id='g_id_onload'")
    expect(response.body).to include("<script src='https://accounts.google.com/gsi/client'")
end

end
describe "Tests when plugin not enabled" do

  before do
    SiteSetting.google_one_tap_enabled = false
    SiteSetting.has_login_hint = false
  end
  it "It should not include script or div container" do
    get "/"
    expect(response.status).to eq(200)
    expect(response.body).to_not include("<div id='g_id_onload'")
    expect(response.body).to_not include("<script src='https://accounts.google.com/gsi/client'")
  end
end
