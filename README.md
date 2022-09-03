# **Google One Tab** Plugin

**Plugin Summary**

For more information, please see: **url to meta topic**



## Background and how this differs from other providres/authenticators 

Google One Tap flow doesn't implement Oauth2 protocol. The main difference is that it's by desing you don't need to make a call to Google to validate the token. Nor is it required to use client secret. 
The validation occuaries mainly by verifying the signature of the token, using one of Google's public keys.

On the otherhand, rendering the sign in/sign up is by design should be handled by Google. Google will inject it's iframe element into the page. So once the user is signed in, Google will send the token to the server. to `POST /auth/google_one_tap/callback` endpoint.

Example of request: 

```
credential: eyJhbGciOiJSUzI1NiIsImtpZCI6IjQwMmYzMDViNzA1ODEzMjlmZjI4OWI1YjNhNjcyODM4MDZlY2E4OTMiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJuYmYiOjE2NjE4Mjk4NDEsImF1ZCI6Ijc5Nzc4NDkxOTY0My1paGk2Y3NzdWJvNGZhcmN0NGRyN2E4Nmc0dDhmNWEwbi5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsInN1YiI6IjEwNzQzMzE5ODMxOTMyMjk2NjQ1MiIsImVtYWlsIjoiZ2hhc3Nhbi5tYXNsYW1hbmlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF6cCI6Ijc5Nzc4NDkxOTY0My1paGk2Y3NzdWJvNGZhcmN0NGRyN2E4Nmc0dDhmNWEwbi5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsIm5hbWUiOiJHaGFzc2FuIE1hc2xhbWFuaSIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS0vQUZkWnVjcDhydm01R1dEWlRQdlFtS2FpRFZDQTVERFR6b01uaWM0aWplM1g3dz1zOTYtYyIsImdpdmVuX25hbWUiOiJHaGFzc2FuIiwiZmFtaWx5X25hbWUiOiJNYXNsYW1hbmkiLCJpYXQiOjE2NjE4MzAxNDEsImV4cCI6MTY2MTgzMzc0MSwianRpIjoiZTZmZDcwYmEyZDBmZDhhY2E0MDkxNmM1NDMyODZmZjA0ZThjNjVjZSJ9.aknnzd_QQm8prUpQnXSCDGstGNziXLLY8YyXSXfnRu3-AsfjO3e7PPsn3EuMWuqbjxbmzK_HlPBTvSf_badaOR5OhteD92G5lHcPAeLDtGYAzW91gQ50gCzPbKeVY-YKJpO_0SlXE7SOMxl1gVLrIKvIjk-Z1tXCwV6GLXaGn5-l9NVgNRkNh5QP35uOKY0aczPqiXSyStYWVdmf6dbv9fZrEJMjoP2vaWPDNKSeu_zJyjoAx04iN-aTNEmtu7b7U7iBDXoRg0U2KgGUKAedALrM57cR6ljq4DxoT3oySR0kYW1LMvegmJ01rNKxAjXN4qcPddir7muI0STAMgddWQ
gsfr_token: 
```

Parsed: 

```json
{
  "iss": "https://accounts.google.com",
  "nbf": 1661829841,
  "aud": "797784919643-ihi6cssubo4farct4dr7a86g4t8f5a0n.apps.googleusercontent.com",
  "sub": "107433198319322966452",
  "email": "ghassan.maslamani@gmail.com",
  "email_verified": true,
  "azp": "797784919643-ihi6cssubo4farct4dr7a86g4t8f5a0n.apps.googleusercontent.com",
  "name": "Ghassan Maslamani",
  "picture": "https://lh3.googleusercontent.com/a-/AFdZucp8rvm5GWDZTPvQmKaiDVCA5DDTzoMnic4ije3X7w=s96-c",
  "given_name": "Ghassan",
  "family_name": "Maslamani",
  "iat": 1661830141,
  "exp": 1661833741,
  "jti": "e6fd70ba2d0fd8aca40916c543286ff04e8c65ce"
}
```

Again the caveate is that when using plugin client_id would be exposed to public (I don't think there is a way to hide it). However discourse no longer would need to know your client secret.

## Account revoke

Revoking is not possile from account prefernce. 
User can revoke directly from their google account: https://myaccount.google.com/permissions.

## How to use: 

- Install like installing any other plugin: https://meta.discourse.org/t/install-plugins-in-discourse/19157 
- Make sure you have clinet_id for google oauth is set in site settings. (_if you are using Google Oauth this should be already defined). To know how to set it Refer to https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid
- Enable `google_one_tap` plguin in site settings


## Next Steps: 

- Getting inital review of the implementation so far.
- Strat writing the tests.
- Decide on what settings are needed. See [this](plugin.rb#24) for more details.
- ~~Decide on how to show the sign in/sign up iframe/popup. See [this](assets/javascripts/discourse/templates/components/login-buttons.hbs) for more details.~~
  - ~~Cureently it shows on all pages.~~ 
  - ~~How to probely show it on login modal.~~
- ~~Test/ensure user avatar is pulled from Google.~~
- ~~Test/ensure user can revoke connection.~~


## Refrences: 
- [Google One Tab Official](https://developers.google.com/identity/gsi/web/)
- [Libray Used to Validate Token](https://github.com/google/google-id-token/blob/v1.4.2/lib/google-id-token.rb)
- [Discourse Topic about this project](https://meta.discourse.org/t/implement-google-one-tap-sign-in/236375)



This work is owned and is funded by: CDCK (_The Company behind discourse.org_).
