# Guide Buddy Switch en français

[README anglais de référence](../../README.md) · [Personas et langues](../personas.md)

Buddy Switch est un exemple public permettant de changer de profil Hermes dans
une même conversation Telegram. `/friend` sert aux échanges légers et `/work`
aux fichiers, recherches et outils.

## Installation

Installez Hermes et créez deux profils :

```bash
hermes profile create buddy-friend --no-skills
hermes profile create buddy-work
```

Installez ensuite Buddy Switch :

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

Quand la barre de progression est terminée, le personnage ASCII du terminal
ouvre les yeux et l'assistant de première configuration démarre. Après le choix
des noms et de la langue, des brouillons SOUL modifiables sont créés dans :

```text
~/.config/buddy-switch/personas/<nom-du-profil>/SOUL.md
```

L'installation n'écrase jamais un `SOUL.md` Hermes existant. Relisez le
brouillon avant de le copier ou de le fusionner.

## Configuration Hermes

Ajoutez ce bloc au `config.yaml` des deux profils :

```yaml
quick_commands:
  friend:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-friend"
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
```

Redémarrez le gateway. Dans Telegram, envoyez `/friend` ou `/work`, attendez 10
à 20 secondes, puis envoyez le message suivant.

## Persona et langue

La langue de réponse est définie dans la politique linguistique du `SOUL.md` de
chaque profil, pas dans le routage. Choisissez aussi un modèle compétent dans
cette langue. Si une modification n'apparaît pas, ouvrez une nouvelle session
ou redémarrez le gateway ; Hermes peut conserver le prompt système d'un agent
ou d'une session.

## Exemples et sécurité

Les images et noms tels que `@mika` et `@forge` sont des exemples de routage ;
le dépôt ne fournit pas cinq personas finalisées. Ne publiez jamais de token,
d'ID de chat ou d'utilisateur, de chemin privé, de log, de state DB, de
conversation ou de SOUL privé. Utilisez des placeholders pour les allowlists.
