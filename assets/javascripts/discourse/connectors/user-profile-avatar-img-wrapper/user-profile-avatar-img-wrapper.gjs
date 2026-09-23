import Component from "@glimmer/component";
import { getOwner } from "@ember/owner";
import { service } from "@ember/service";
import { getURLWithCDN } from "discourse/lib/get-url";
import { prefersReducedMotion } from "discourse/lib/utilities";
import dBoundAvatar from "discourse/ui-kit/helpers/d-bound-avatar";

const HUGE = 144;

export default class AnimatedProfileAvatar extends Component {
  @service siteSettings;

  // The profile header renders collapsed (section.collapsed-info) on your own
  // summary page and on non-summary tabs, showing a small avatar; the toggle
  // flips forceExpand. With animated_avatars_expanded_profile_only on, only the
  // expanded big avatar animates — collapsed keeps the regular static avatar
  // and the gif is never fetched.
  get collapsed() {
    if (!this.siteSettings.animated_avatars_expanded_profile_only) {
      return false;
    }

    return getOwner(this).lookup("controller:user")?.collapsedInfo ?? false;
  }

  get animatedUrl() {
    const url = this.args.outletArgs.user?.animated_avatar;

    if (!url || this.collapsed || prefersReducedMotion()) {
      return null;
    }

    return getURLWithCDN(url);
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
