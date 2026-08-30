# frozen_string_literal: true

RSpec.describe DiscourseAnimatedAvatars::AnimatedAvatarsController do
  fab!(:user) { Fabricate(:user, trust_level: TrustLevel[3], refresh_auto_groups: true) }
  fab!(:low_tl_user) { Fabricate(:user, trust_level: TrustLevel[0], refresh_auto_groups: true) }
  fab!(:animated_upload) { Fabricate(:upload, user: user, extension: "gif", animated: true) }
  fab!(:static_upload) { Fabricate(:upload, user: user, extension: "png", animated: false) }

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
  end

  it "refuses users below the trust level" do
    sign_in(low_tl_user)
    put "/u/#{low_tl_user.username}/animated-avatar.json", params: { upload_id: animated_upload.id }
    expect(response.status).to eq(403)
  end
end
