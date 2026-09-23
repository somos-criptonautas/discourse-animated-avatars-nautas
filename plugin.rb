# frozen_string_literal: true
# name: discourse-animated-avatars
# about: This plugin adds support for animated avatars
# version: 0.1
# authors: Discourse, Criptonautas
# url: https://github.com/discourse/discourse-animated-avatars

module ::DiscourseAnimatedAvatars
  PLUGIN_NAME = "discourse-animated-avatars"
  UPLOAD_FIELD = "animated_avatar_upload_id"
end

require_relative "lib/discourse_animated_avatars/engine"

after_initialize do
  reloadable_patch do
    gifsicle_installed =
      begin
        Discourse::Utils.execute_command(
          "gifsicle",
          "--version",
          "&>",
          "/dev/null",
          failure_message: "gifsicle not found",
        )
        true
      rescue StandardError
        false
      end

    # new crop functions if gifsicle is installed
    if gifsicle_installed
      UploadCreator.prepend(DiscourseAnimatedAvatars::UploadCreatorGifsicleExtension)
    else
      # fallback if no gifsicle, no cropping for animated avatars
      UploadCreator.prepend(DiscourseAnimatedAvatars::UploadCreatorNoGifsicleExtension)
    end
    UploadCreator.prepend(DiscourseAnimatedAvatars::UploadCreatorAnimatedWebpExtension)
    UploadCreator.prepend(DiscourseAnimatedAvatars::UploadCreatorGifToWebpExtension)

    OptimizedImage.prepend(DiscourseAnimatedAvatars::OptimizedImageExtension)
    UserAvatarsController.prepend(DiscourseAnimatedAvatars::UserAvatarsControllerExtension)
  end

  register_user_custom_field_type(DiscourseAnimatedAvatars::UPLOAD_FIELD, :integer)

  # keeps the upload out of the orphan cleanup job
  register_upload_in_use do |upload|
    UserCustomField.exists?(name: DiscourseAnimatedAvatars::UPLOAD_FIELD, value: upload.id.to_s)
  end

  add_to_class(:user, :can_use_animated_avatar?) do
    staff? || trust_level >= SiteSetting.animated_avatars_min_trust_level_to_display
  end

  # ponytail: serves the full cropped upload (gif or webp, avatar_sizes.max) at 144px.
  # Swap for an OptimizedImage if the weight ever shows up in page timings.
  add_to_class(:user, :animated_avatar) do
    return nil unless can_use_animated_avatar?
    upload_id = custom_fields[DiscourseAnimatedAvatars::UPLOAD_FIELD]
    Upload.find_by(id: upload_id)&.url if upload_id
  end

  # user_card only (UserSerializer inherits it): reading custom_fields per post
  # author would be an N+1 on every topic page, and posts never animate.
  add_to_serializer(:user_card, :animated_avatar) do
    user.try(:animated_avatar)
  rescue StandardError
    nil
  end

  add_to_serializer(:user, :can_use_animated_avatar) { object.can_use_animated_avatar? }
end

Discourse::Application.routes.append do
  put "/u/:username/animated-avatar" => "discourse_animated_avatars/animated_avatars#update",
      :constraints => {
        username: RouteFormat.username,
      }

  %i[gif webp].each do |fmt|
    get "user_avatar/:hostname/:username/:size/:version.#{fmt}" => "user_avatars#show",
        :constraints => {
          hostname: /[\w\.-]+/,
          size: /\d+/,
          username: RouteFormat.username,
          format: fmt,
        }
  end
end
