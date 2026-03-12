import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("Google One Tap when disabled", function (needs) {
  needs.settings({
    google_one_tap_enabled: false,
  });

  needs.pretender((server, helper) => {
    server.get("/session/passkey/challenge.json", () => {
      return helper.response({ challenge: "123" });
    });
  });

  test("doesn't show on login modal", async function (assert) {
    await visit("");
    await click(".login-button");
    assert.dom("#google_one_tap").doesNotExist();
  });

  test("doesn't show on sign up modal", async function (assert) {
    await visit("");
    await click(".sign-up-button");
    assert.dom("#google_one_tap").doesNotExist();
  });
});

acceptance("Google One Tap when enabled", function (needs) {
  needs.settings({
    google_one_tap_enabled: true,
  });

  needs.pretender((server, helper) => {
    server.get("/session/passkey/challenge.json", () => {
      return helper.response({ challenge: "123" });
    });
  });

  test("shows up on login modal", async function (assert) {
    await visit("");
    await click(".login-button");
    assert.dom("#google_one_tap").exists();
  });

  test("shows up on sign up", async function (assert) {
    await visit("");
    await click(".sign-up-button");
    assert.dom("#google_one_tap").exists();
  });
});
