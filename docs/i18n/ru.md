# Руководство Buddy Switch на русском

[Основной README на английском](../../README.md) · [Персоны и языки](../personas.md)

Buddy Switch — открытый пример переключения профилей Hermes в одном чате
Telegram. `/friend` предназначен для обычного общения, а `/work` — для файлов,
поиска и инструментов.

## Установка

Сначала установите Hermes и создайте два профиля:

```bash
hermes profile create buddy-friend --no-skills
hermes profile create buddy-work
```

Затем установите Buddy Switch:

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

![Установщик Buddy Switch, запущенный в терминале](../../assets/buddy-switch-screenshot.png)

После завершения индикатора персонаж ASCII в терминале открывает глаза и
запускается первоначальная настройка. После выбора имён и языка редактируемые
черновики SOUL появятся здесь:

```text
~/.config/buddy-switch/personas/<имя-профиля>/SOUL.md
```

Установщик не перезаписывает существующий `SOUL.md` Hermes. Сначала проверьте
черновик, затем скопируйте или объедините его вручную.

## Настройка Hermes

Добавьте этот блок в `config.yaml` обоих профилей:

```yaml
quick_commands:
  friend:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-friend"
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
```

Перезапустите gateway. В Telegram отправьте `/friend` или `/work`, подождите
10–20 секунд и отправьте следующее сообщение.

## Персона и язык

Язык ответа задаётся языковой политикой в `SOUL.md` каждого профиля, а не
маршрутизацией. Нужна также модель, хорошо работающая на выбранном языке. Если
изменение SOUL не видно, начните новую сессию или перезапустите gateway: Hermes
может сохранять системный prompt на время работы agent или session.

## Примеры и безопасность

Изображения и имена `@mika`, `@forge` — только примеры маршрутов; пять готовых
персон в репозитории не поставляются. Не публикуйте токены, chat/user ID, личные
пути, логи, state DB, переписку или приватный SOUL. В Telegram allowlist
используйте placeholders.
