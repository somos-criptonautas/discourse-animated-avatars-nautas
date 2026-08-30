# frozen_string_literal: true

module DiscourseAnimatedAvatars
  class AnimatedAvatarsController < ::ApplicationController
    requires_plugin DiscourseAnimatedAvatars::PLUGIN_NAME
    requires_login

    # PUT /u/:username/animated-avatar.json
    # upload_id blank clears the animated avatar
    def update
      user = fetch_user_from_params
      guardian.ensure_can_edit!(user)
      raise Discourse::InvalidAccess.new unless user.can_use_animated_avatar?

      upload_id = params[:upload_id].presence

      if upload_id.nil?
        user.custom_fields.delete(DiscourseAnimatedAvatars::UPLOAD_FIELD)
      else
        upload = Upload.find_by(id: upload_id)
        return render_json_error(I18n.t("animated_avatars.missing_upload")) if upload.nil?

        return render_json_error(I18n.t("animated_avatars.not_animated")) unless upload.animated?

        user.custom_fields[DiscourseAnimatedAvatars::UPLOAD_FIELD] = upload.id
      end

      user.save_custom_fields

      render json: success_json.merge(animated_avatar: user.animated_avatar)
    end
  end
end
