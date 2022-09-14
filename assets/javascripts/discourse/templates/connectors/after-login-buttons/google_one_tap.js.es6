export default {
  actions: {
    didInsertElement() {
      if (window.google) {
        window.google.accounts.id.renderButton(
          document.getElementById("google_one_tap"),
          { theme: "outline", size: "large", width: 200 }
        );
      }
    },
  },
  shouldRender(_, component) {
    return component.siteSettings.google_one_tap_enabled;
  },
};
