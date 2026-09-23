import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse/lib/object";
import userFixtures from "discourse/tests/fixtures/user-fixtures";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";
import Topics from "../fixtures/topic-fixtures";

acceptance("Animated avatars topic tests", function (needs) {
  needs.pretender((server, helper) => {
    const topicPath = "/t/1000.json";
    const topicResponse = Topics[topicPath];
    server.get(topicPath, () => helper.response(topicResponse));
  });

  test("posts never render the animated avatar", async function (assert) {
    await visit("/t/-/1000");
    assert
      .dom(".topic-post img.avatar[src$='.gif']")
      .doesNotExist("keeps the static avatar in topics");
    assert
      .dom(".animated-avatar")
      .doesNotExist("adds no animated marker outside cards and profiles");
  });
});

function withAnimatedAvatar(server, helper) {
  const payload = cloneJSON(userFixtures["/u/eviltrout.json"]);
  payload.user.animated_avatar = "/uploads/default/original/1X/123456.gif";
  server.get("/u/eviltrout.json", () => helper.response(payload));
}

acceptance("Animated avatars profile tests", function (needs) {
  needs.user();
  needs.pretender(withAnimatedAvatar);

  test("animates only while the profile header is expanded", async function (assert) {
    await visit("/u/eviltrout/summary");

    const collapsed = `button[aria-controls="collapsed-info-panel"][aria-expanded="false"]`;
    const expanded = `button[aria-controls="collapsed-info-panel"][aria-expanded="true"]`;

    assert
      .dom(".user-profile-avatar img.animated-avatar")
      .doesNotExist("collapsed header keeps the static avatar");

    await click(collapsed);
    assert
      .dom(".user-profile-avatar img.animated-avatar")
      .exists("expanded header shows the animated avatar");

    await click(expanded);
    assert
      .dom(".user-profile-avatar img.animated-avatar")
      .doesNotExist("collapsing again restores the static avatar");
  });
});

acceptance(
  "Animated avatars profile tests - expanded-only disabled",
  function (needs) {
    needs.user();
    needs.settings({ animated_avatars_expanded_profile_only: false });
    needs.pretender(withAnimatedAvatar);

    test("animates in the collapsed header too", async function (assert) {
      await visit("/u/eviltrout/summary");

      assert
        .dom(
          `button[aria-controls="collapsed-info-panel"][aria-expanded="false"]`
        )
        .exists("header starts collapsed");
      assert
        .dom(".user-profile-avatar img.animated-avatar")
        .exists("animates even while collapsed when the setting is off");
    });
  }
);
