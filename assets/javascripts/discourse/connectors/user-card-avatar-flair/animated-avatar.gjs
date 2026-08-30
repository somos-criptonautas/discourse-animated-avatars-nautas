import Component from "@glimmer/component";
import { modifier } from "ember-modifier";
import { getURLWithCDN } from "discourse/lib/get-url";
import { prefersReducedMotion } from "discourse/lib/utilities";

// ponytail: core exposes no outlet around the card avatar itself, so we reach
// for the sibling img. Replace with a proper outlet if core ever adds one.
const swapAvatar = modifier((element, [url]) => {
  const img = element.closest(".user-card-avatar")?.querySelector("img.avatar");

  if (!img || !url) {
    return;
  }

  // no teardown: dBoundAvatar re-renders the img from avatar_template whenever
  // the card switches user, so the static src is already back before we re-run
  img.src = url;
  img.classList.add("animated-avatar");
});

export default class AnimatedCardAvatar extends Component {
  get animatedUrl() {
    const url = this.args.outletArgs.user?.animated_avatar;
    return url && !prefersReducedMotion() ? getURLWithCDN(url) : null;
  }

  <template>
    <span {{swapAvatar this.animatedUrl}}></span>
  </template>
}
