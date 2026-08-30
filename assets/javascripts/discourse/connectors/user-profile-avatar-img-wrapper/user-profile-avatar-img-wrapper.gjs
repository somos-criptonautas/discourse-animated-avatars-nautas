import Component from "@glimmer/component";
import { getURLWithCDN } from "discourse/lib/get-url";
import { prefersReducedMotion } from "discourse/lib/utilities";
import dBoundAvatar from "discourse/ui-kit/helpers/d-bound-avatar";

const HUGE = 144;

export default class AnimatedProfileAvatar extends Component {
  get animatedUrl() {
    const url = this.args.outletArgs.user?.animated_avatar;
    return url && !prefersReducedMotion() ? getURLWithCDN(url) : null;
  }

  <template>
    {{#if this.animatedUrl}}
      <img
        class="avatar animated-avatar"
        width={{HUGE}}
        height={{HUGE}}
        alt=""
        src={{this.animatedUrl}}
      />
    {{else}}
      {{dBoundAvatar @outletArgs.user "huge"}}
    {{/if}}
  </template>
}
