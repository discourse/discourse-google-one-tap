# Google One Tap Plugin

This plugin adds support for Google One Tap sign-in and sign-up to Discourse. When this plugin is installed and configured, anonymous users will see the following prompt:

<img width="450" src="https://user-images.githubusercontent.com/17474474/196159737-f290f117-3cf6-46dc-9df9-804e61ccede3.png">

For more information and instructions for installing/configuring the plugin, please see: https://meta.discourse.org/t/google-one-tap-login-signup/242510.

## Implementation

When an anonymous user requests a page, the plugin injects into the page a couple of HTML elements:

1. A `<div>` tag that will contain the Google One Tap prompt iframe

2. A `<script>` tag that loads the Google One Tap JavaScript bundle from Google's servers.

The `<script>` tag is responsible for rendering the Google One Tap prompt into the `<div>` tag and making it visible to the user. Then when the user selects an email address from the prompt, it will open a popup window with a confirmation screen from Google to request the user's consent to share personal information with the site. If the user consents (or they've previously consented), a `POST` request is made to `/auth/google_one_tap/callback` with a JSON Web Token (JWT) that contains the user's information. The plugin will then decode the JWT and perform a few validations:

1. Ensure the JWT is signed with one of [Google's keys](https://www.googleapis.com/oauth2/v1/certs)

2. Ensure the JWT isn't expired

3. Ensure the client ID in the JWT matches the client ID in the `google_oauth2_client_id` setting

4. Ensure the `POST` request passes CSRF-protection checks

If any of these validations fails, an error message is shown to the user and nothing happens. Otherwise, if the email address in the JWT matches an existing email, that user is logged in. If the email address is the JWT doesn't match an existing email, the user is shown the Discourse sign-up form pre-populated with the information included in the JWT from Google and the user can adjust their name and/or username and then finish creating their account.

## Credits

This plugin was originally built by [Ghassan Maslamani](https://meta.discourse.org/u/ghassan).
