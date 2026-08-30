# discourse-animated-avatars

Lets users upload a **second, animated avatar** alongside their regular one.

The regular avatar is used everywhere — posts, topic lists, the header, the sidebar. The animated
one is shown only on the user's profile page and user card, and only for users at or above
`animated_avatars_min_trust_level_to_display`. Users upload it from Preferences → Account.

## Enable gif resizing

Optionally, your `app.yml` may be configured to install gifsicle in addition to the plugin.

This allows gif uploads to be cropped and resized to fit a square avatar. If the dependency is not included,
gif uploads will keep the original aspect ratio.

```
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/discourse/discourse-animated-avatars.git
    - exec:
        cd: $home/plugins/discourse-animated-avatars
        raise_on_fail: false
        cmd:
          - $home/plugins/discourse-animated-avatars/scripts/install.sh
```
