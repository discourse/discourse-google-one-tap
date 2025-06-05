import Component from "@ember/component";
import { action } from "@ember/object";
import { classNames, tagName } from "@ember-decorators/component";

@tagName("")
@classNames("after-login-buttons-outlet", "google-one-tap")
export default class GoogleOneTap extends Component {
  static shouldRender(_, context) {
    return context.siteSettings.google_one_tap_enabled;
  }

  @action
  didInsertElement() {
    super.didInsertElement(...arguments);
    if (window.google) {
      window.google.accounts.id.renderButton(
        document.getElementById("google_one_tap"),
        {
          theme: "outline",
          size: "large",
          width: 200,
          locale: this.siteSettings.default_locale,
        }
      );
    }
  }

  <template>
    <div class="btn-social" id="google_one_tap"></div>
  </template>
}
