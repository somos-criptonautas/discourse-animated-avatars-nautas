import { visit } from "@ember/test-helpers";
import { test } from "qunit";
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
