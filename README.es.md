# discourse-animated-avatars

[ENGLISH](README.md) | **ESPAÑOL**

Permite a los usuarios subir un **segundo avatar animado** (gif o webp) junto a su avatar normal.

El avatar normal se usa en todas partes: posts, listas de temas, cabecera, barra lateral. El animado
solo se muestra en la página de perfil y en la tarjeta de usuario, y solo para usuarios con nivel igual o superior a
`animated_avatars_min_trust_level_to_display`. Los usuarios lo suben desde Preferencias → Cuenta.

## Ajustes

- `animated_avatars_min_trust_level_to_display`: nivel de confianza mínimo para subir y mostrar un avatar animado. (por defecto 3)
- `animated_avatars_expanded_profile_only`: anima el avatar del perfil solo mientras la cabecera del perfil está expandida; la cabecera colapsada mantiene el avatar estático normal. (por defecto: true)
- `animated_gif_avatar_to_webp`: convierte automáticamente los avatares gif animados a webp al subirlos, reduciendo el tamaño del archivo. (por defecto: true)
- `animated_gif_avatar_webp_quality`: calidad de la conversión de gif a webp. Se recomienda entre 75% y 100% (por defecto: 80%)

## Activar el redimensionado de gif

Opcionalmente, tu `app.yml` puede configurarse para instalar gifsicle además del plugin.

Esto permite recortar y redimensionar las subidas de gif para ajustarlas a un avatar cuadrado. Si no se incluye la dependencia,
los gif conservan su relación de aspecto original. La dependencia no es necesaria para la conversión automática de gif a webp.

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

## Licencia

MIT (upstream: Civilized Discourse Construction Kit, Inc.). Modificaciones © 2026 Criptonautas. Consulta [LICENSE](LICENSE).

Texto de este README bajo [CC BY-NC-SA 4.0](CC-BY-NC-SA-4.0.txt).
