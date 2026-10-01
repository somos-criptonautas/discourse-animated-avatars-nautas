# discourse-animated-avatars-nautas

**ENGLISH** | [ESPAÑOL](README.es.md)

Lets users upload a **second, animated avatar** (gif or webp) alongside their regular one.

The regular avatar is used everywhere — posts, topic lists, the header, the sidebar. The animated
one is shown only on the user's profile page and user card, and only for users at or above
`animated_avatars_min_trust_level_to_display`. Users upload it from Preferences → Account.

## Settings

- `animated_avatars_min_trust_level_to_display` - minimum trust level to upload and display an animated avatar. (default 3)
- `animated_avatars_expanded_profile_only` - only animate the profile avatar while the profile header is expanded; the collapsed header keeps the regular static avatar. (default: true)
- `animated_gif_avatar_to_webp` - auto converts animated gif avatars to webp on upload, reducing file size. (default: true)
- `animated_gif_avatar_webp_quality` - the quality of the converted gif to webp. Recommended settings between 75% to 100% (default: 80%)

## Enable gif resizing

Optionally, your `app.yml` may be configured to install gifsicle in addition to the plugin.

This allows gif uploads to be cropped and resized to fit a square avatar. If the dependency is not included,
gif uploads will keep the original aspect ratio. The dependency is not required for auto gif to webp conversion.

```
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/somos-criptonautas/discourse-animated-avatars-nautas.git
    - exec:
        cd: $home/plugins/discourse-animated-avatars-nautas
        raise_on_fail: false
        cmd:
          - $home/plugins/discourse-animated-avatars-nautas/scripts/install.sh
```

## License

MIT (upstream: Civilized Discourse Construction Kit, Inc.). Modifications © 2026 Criptonautas. See [LICENSE](LICENSE).

Text of this README under [CC BY-NC-SA 4.0](CC-BY-NC-SA-4.0.txt).
