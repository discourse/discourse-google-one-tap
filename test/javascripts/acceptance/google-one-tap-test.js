import { acceptance, exists } from "discourse/tests/helpers/qunit-helpers";
import { click, visit } from "@ember/test-helpers";

import { test } from "qunit";

acceptance("Google One Tap when disabled", function (needs) {
  needs.settings({
    google_one_tap_enabled: false,
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
