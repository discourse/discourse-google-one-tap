import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance, exists } from "discourse/tests/helpers/qunit-helpers";

acceptance("Google One Tap when disabled", function (needs) {
  needs.settings({
    google_one_tap_enabled: false,
  });

  needs.pretender((server, helper) => {
    server.get("/session/passkey/challenge.json", () => {
      return helper.response({ challenge: "123" });
    });
  });

  test("it doesn't show on login modal", async function (assert) {
    await visit("");
    await click(".login-button");
    assert.notOk(exists("#google_one_tap"));
  });
  test("it doesn't show on sign up modal", async function (assert) {
    await visit("");
    await click(".sign-up-button");
    assert.notOk(exists("#google_one_tap"));
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

  test("it should show up on login modal", async function (assert) {
    await visit("");
    await click(".login-button");
    assert.ok(exists("#google_one_tap"));
  });

  test("it should show up on sign up", async function (assert) {
    await visit("");
    await click(".sign-up-button");
    assert.ok(exists("#google_one_tap"));
  });
});
