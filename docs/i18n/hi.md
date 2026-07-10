# Buddy Switch हिन्दी मार्गदर्शिका

[मुख्य अंग्रेज़ी README](../../README.md) · [Persona और भाषा सेटअप](../personas.md)

Buddy Switch एक सार्वजनिक उदाहरण है जो एक ही Telegram सतह से Hermes profiles
बदलता है। `/friend` हल्की बातचीत के लिए और `/work` फ़ाइल, खोज व tool कार्यों के लिए है।

## इंस्टॉल करें

पहले Hermes इंस्टॉल करके दो profiles बनाएँ:

```bash
hermes profile create buddy-friend --no-skills
hermes profile create buddy-work
```

फिर Buddy Switch इंस्टॉल करें:

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

![टर्मिनल में चल रहा Buddy Switch इंस्टॉलर](../../assets/buddy-switch-screenshot.png)

Progress bar पूरा होने पर terminal का ASCII पात्र आँखें खोलता है और पहली setup
शुरू होती है। Profile नाम और default response language चुनने के बाद editable SOUL
drafts यहाँ बनते हैं:

```text
~/.config/buddy-switch/personas/<profile-name>/SOUL.md
```

Installer किसी मौजूदा Hermes `SOUL.md` को overwrite नहीं करता। Draft जाँचकर ही
उसे merge या copy करें।

## Hermes configuration

दोनों profile की `config.yaml` में यह block जोड़ें:

```yaml
quick_commands:
  friend:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-friend"
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
```

Gateway restart करें। Telegram में `/friend` या `/work` भेजें, 10-20 सेकंड रुकें,
फिर अगला संदेश भेजें।

## Persona और भाषा

Response language हर profile के `SOUL.md` की language policy से तय होती है, routing
config से नहीं। लक्ष्य भाषा में सक्षम model चुनना भी ज़रूरी है। SOUL बदलने के बाद असर
न दिखे तो नया session शुरू करें या संबंधित gateway restart करें, क्योंकि Hermes system
prompt को agent या session के दौरान cache कर सकता है।

## उदाहरण और सुरक्षा

चित्र तथा `@mika`, `@forge` जैसे नाम केवल routing examples हैं; पाँच तैयार personas
शामिल नहीं हैं। Token, chat/user ID, निजी path, log, state DB, transcript या निजी SOUL
commit न करें। Telegram allowlist साझा करते समय placeholders इस्तेमाल करें।
