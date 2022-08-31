# frozen_string_literal: true

# name: google-one-tap
# about: Something
# version: 0.0.1
# authors: Discourse
# url: https://github.com/ghassanmas/discourse-google-one-tap
# required_version: 2.7.0

enabled_site_setting :google_one_tap_enabled

gem "google-id-token", '1.4.2'

require_relative "lib/google_one_tap"
require_relative "lib/google_one_tap_authenticator"
register_asset "stylesheets/google_one_tap.scss"

after_initialize do

  register_html_builder('server:before-head-close') do
    "<script src='https://accounts.google.com/gsi/client' async defer></script>"
  end

  register_html_builder('server:before-body-close') do |ctx|
    #This return the div Google JS (loaded above will use)
    #This could also be done in pure JS
    #Ref: https://developers.google.com/identity/gsi/web/reference/js-reference
    # Admin needs to be *really catious* when chaning ifram/container style qouting Google:
    #> Warning: Do not hide any One Tap prompt content.
    #> Do not obscure the perception that the One Tap prompt content is from a Google iframe.
    #> Failure to do so may result in project suspension, account suspension, or both.
    # Ref https://developers.google.com/identity/gsi/web/guides/change-position
    result = ""
    unless (ctx.current_user || !(ctx.request.cookies["authentication_data"].blank?)) #If user is authenticated or (about to create account). don't show the Popup
      result += "<div id='g_id_onload' "
        result += "data-prompt_parent_id='g_id_onload'"
        result += "data-client_id=" + SiteSetting.google_oauth2_client_id + " "
        result += "data-login_uri='/auth/google_one_tap/callback' "
        result += "data-itp_support='true' "
        result += "style='position: absolute; top: 100px; right: 30px; width: 400px; height: 200px; z-index: 1001;'> " # Todo load style values from plugin settings*.
        result += "</div>"
    end
    result
  end
end
auth_provider authenticator: GoogleOneTapAuthenticator.new
