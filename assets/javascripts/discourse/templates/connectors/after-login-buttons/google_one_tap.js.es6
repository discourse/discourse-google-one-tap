export default {
  actions: {
    didInsertElement() {
      window.google.accounts.id.renderButton(
        document.getElementById("google_one_tap"),
        { theme: "outline", size: "large" }
      );
    },
  },
};
