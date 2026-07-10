# Guía de Buddy Switch en español

[README principal en inglés](../../README.md) · [Personas e idiomas](../personas.md)

Buddy Switch es un ejemplo público para cambiar perfiles de Hermes desde una
misma conversación de Telegram. `/friend` sirve para charlar y `/work` para
archivos, búsquedas y herramientas.

## Instalación

Instala Hermes y crea dos perfiles:

```bash
hermes profile create buddy-friend --no-skills
hermes profile create buddy-work
```

Después instala Buddy Switch:

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

Al terminar la barra de progreso, el personaje ASCII del terminal abre los ojos
y comienza la configuración inicial. Tras elegir los nombres y el idioma, se
crean borradores editables de SOUL en:

```text
~/.config/buddy-switch/personas/<nombre-del-perfil>/SOUL.md
```

El instalador nunca sobrescribe un `SOUL.md` de Hermes. Revisa el borrador antes
de copiarlo o combinarlo.

## Configuración de Hermes

Añade este bloque al `config.yaml` de ambos perfiles:

```yaml
quick_commands:
  friend:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-friend"
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
```

Reinicia el gateway. En Telegram, envía `/friend` o `/work`, espera entre 10 y
20 segundos y luego envía el siguiente mensaje.

## Persona e idioma

El idioma de respuesta se define en la política de idioma del `SOUL.md` de cada
perfil, no en el enrutamiento. Elige también un modelo competente en ese idioma.
Si un cambio no aparece, inicia una sesión nueva o reinicia el gateway: Hermes
puede conservar el prompt del sistema durante la vida del agente o la sesión.

## Ejemplos y seguridad

Las imágenes y nombres como `@mika` o `@forge` son ejemplos de rutas; el
repositorio no incluye cinco personas terminadas. No publiques tokens, IDs de
chat o usuario, rutas privadas, logs, state DB, conversaciones ni SOUL privados.
Usa placeholders al compartir allowlists de Telegram.
