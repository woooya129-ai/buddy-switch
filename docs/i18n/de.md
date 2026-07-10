# Buddy Switch Anleitung auf Deutsch

[Maßgebliche englische README](../../README.md) · [Personas und Sprachen](../personas.md)

Buddy Switch ist ein öffentliches Beispiel zum Umschalten von Hermes-Profilen
in derselben Telegram-Unterhaltung. `/friend` ist für lockere Gespräche und
`/work` für Dateien, Recherche und Werkzeuge gedacht.

## Installation

Installiere zuerst Hermes und erstelle zwei Profile:

```bash
hermes profile create buddy-friend --no-skills
hermes profile create buddy-work
```

Installiere danach Buddy Switch:

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

Nach dem Fortschrittsbalken öffnet die ASCII-Figur im Terminal die Augen und
die Ersteinrichtung beginnt. Nach Auswahl der Profilnamen und Sprache entstehen
bearbeitbare SOUL-Entwürfe unter:

```text
~/.config/buddy-switch/personas/<profilname>/SOUL.md
```

Der Installer überschreibt keine vorhandene Hermes-`SOUL.md`. Prüfe den Entwurf
und kopiere oder kombiniere ihn anschließend manuell.

## Hermes konfigurieren

Füge diesen Block in die `config.yaml` beider Profile ein:

```yaml
quick_commands:
  friend:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-friend"
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
```

Starte das Gateway neu. Sende in Telegram `/friend` oder `/work`, warte 10 bis
20 Sekunden und sende dann die nächste Nachricht.

## Persona und Sprache

Die Antwortsprache wird in der Sprachrichtlinie der jeweiligen `SOUL.md`
festgelegt, nicht im Routing. Wähle außerdem ein Modell, das diese Sprache gut
beherrscht. Falls eine Änderung nicht erscheint, beginne eine neue Session oder
starte das Gateway neu; Hermes kann den System-Prompt während eines Agents oder
einer Session zwischenspeichern.

## Beispiele und Sicherheit

Die Bilder und Namen wie `@mika` oder `@forge` sind Routing-Beispiele; fünf
fertige Personas werden nicht mitgeliefert. Veröffentliche keine Tokens,
Chat-/User-IDs, privaten Pfade, Logs, State-DBs, Unterhaltungen oder privaten
SOUL-Dateien. Nutze beim Teilen von Telegram-Allowlists Platzhalter.
