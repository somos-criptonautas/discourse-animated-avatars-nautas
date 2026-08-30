import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import UppyImageUploader from "discourse/components/uppy-image-uploader";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class AnimatedAvatarUploader extends Component {
  @tracked url = this.args.outletArgs.model?.animated_avatar;

  get user() {
    return this.args.outletArgs.model;
  }

  @action
  uploadDone(upload) {
    this.#save(upload.id);
  }

  @action
  uploadDeleted() {
    this.#save(null);
  }

  async #save(uploadId) {
    try {
      const result = await ajax(
        `/u/${this.user.username}/animated-avatar.json`,
        { type: "PUT", data: { upload_id: uploadId } }
      );
      this.url = result.animated_avatar;
      this.user.set("animated_avatar", result.animated_avatar);
    } catch (e) {
      popupAjaxError(e);
    }
  }

  <template>
    {{#if this.user.can_use_animated_avatar}}
      <div class="control-group pref-animated-avatar">
        <label class="control-label">{{i18n "animated_avatars.title"}}</label>
        <UppyImageUploader
          @id="animated-avatar-uploader"
          @type="avatar"
          @imageUrl={{this.url}}
          @onUploadDone={{this.uploadDone}}
          @onUploadDeleted={{this.uploadDeleted}}
        />
        <div class="instructions">{{i18n "animated_avatars.instructions"}}</div>
      </div>
    {{/if}}
  </template>
}
