# frozen_string_literal: true

RSpec.describe DiscourseAnimatedAvatars::AnimatedAvatarsController do
  fab!(:user) { Fabricate(:user, trust_level: TrustLevel[3], refresh_auto_groups: true) }
  fab!(:low_tl_user) { Fabricate(:user, trust_level: TrustLevel[0], refresh_auto_groups: true) }
  fab!(:animated_upload) { Fabricate(:upload, user: user, extension: "gif", animated: true) }
  fab!(:static_upload) { Fabricate(:upload, user: user, extension: "png", animated: false) }
  fab!(:other_user, :user)
  fab!(:other_upload) { Fabricate(:upload, user: other_user, extension: "gif", animated: true) }

  before do
    enable_current_plugin
    SiteSetting.animated_avatars_min_trust_level_to_display = TrustLevel[3]
  end

  it "requires login" do
    put "/u/#{user.username}/animated-avatar.json", params: { upload_id: animated_upload.id }
    expect(response.status).to eq(403)
  end

  context "when signed in" do
    before { sign_in(user) }

    it "sets and clears the animated avatar" do
      put "/u/#{user.username}/animated-avatar.json", params: { upload_id: animated_upload.id }
      expect(response.status).to eq(200), response.body
      expect(user.reload.animated_avatar).to eq(animated_upload.url)

      put "/u/#{user.username}/animated-avatar.json", params: { upload_id: "" }
      expect(response.status).to eq(200), response.body
      expect(user.reload.animated_avatar).to eq(nil)
    end

    it "rejects a non-animated upload" do
      put "/u/#{user.username}/animated-avatar.json", params: { upload_id: static_upload.id }
      expect(response.status).to eq(422)
      expect(user.reload.animated_avatar).to eq(nil)
    end

    it "does not let a user edit someone else" do
      put "/u/#{low_tl_user.username}/animated-avatar.json",
          params: {
            upload_id: animated_upload.id,
          }
      expect(response.status).to eq(403)
    end

    it "refuses someone else's upload and accepts the user's own" do
      put "/u/#{user.username}/animated-avatar.json", params: { upload_id: other_upload.id }
      expect(response.status).to eq(403)
      expect(user.reload.animated_avatar).to eq(nil)

      put "/u/#{user.username}/animated-avatar.json", params: { upload_id: animated_upload.id }
      expect(response.status).to eq(200), response.body
      expect(user.reload.animated_avatar).to eq(animated_upload.url)
    end

    it "accepts a deduplicated upload linked to the user" do
      UserUpload.create!(upload: other_upload, user: user)

      put "/u/#{user.username}/animated-avatar.json", params: { upload_id: other_upload.id }
      expect(response.status).to eq(200), response.body
      expect(user.reload.animated_avatar).to eq(other_upload.url)
    end

    it "refuses an upload when SSO overrides avatars, but still clears" do
      user.custom_fields[DiscourseAnimatedAvatars::UPLOAD_FIELD] = animated_upload.id
      user.save_custom_fields
      SiteSetting.discourse_connect_overrides_avatar = true

      put "/u/#{user.username}/animated-avatar.json", params: { upload_id: animated_upload.id }
      expect(response.status).to eq(403)

      put "/u/#{user.username}/animated-avatar.json", params: { upload_id: "" }
      expect(response.status).to eq(200), response.body
      expect(user.reload.animated_avatar).to eq(nil)
    end

    it "refuses an upload when the user is outside the allowed groups" do
      SiteSetting.uploaded_avatars_allowed_groups = Group::AUTO_GROUPS[:admins]

      put "/u/#{user.username}/animated-avatar.json", params: { upload_id: animated_upload.id }
      expect(response.status).to eq(403)
      expect(user.reload.animated_avatar).to eq(nil)
    end
  end

  context "when a moderator edits a member" do
    fab!(:moderator)
    fab!(:moderator_upload) do
      Fabricate(:upload, user: moderator, extension: "gif", animated: true)
    end

    before { sign_in(moderator) }

    it "accepts the moderator's own upload" do
      put "/u/#{user.username}/animated-avatar.json", params: { upload_id: moderator_upload.id }
      expect(response.status).to eq(200), response.body
      expect(user.reload.animated_avatar).to eq(moderator_upload.url)
    end

    it "accepts the member's upload" do
      put "/u/#{user.username}/animated-avatar.json", params: { upload_id: animated_upload.id }
      expect(response.status).to eq(200), response.body
      expect(user.reload.animated_avatar).to eq(animated_upload.url)
    end

    it "refuses a third user's upload" do
      put "/u/#{user.username}/animated-avatar.json", params: { upload_id: other_upload.id }
      expect(response.status).to eq(403)
      expect(user.reload.animated_avatar).to eq(nil)
    end
  end

  it "refuses users below the trust level" do
    sign_in(low_tl_user)
    put "/u/#{low_tl_user.username}/animated-avatar.json", params: { upload_id: animated_upload.id }
    expect(response.status).to eq(403)
  end
end
