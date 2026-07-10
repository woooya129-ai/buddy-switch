# Buddy Switch 日本語ガイド

[英語の基準 README](../../README.md) · [ペルソナと言語設定](../personas.md)

Buddy Switch は、同じ Telegram 画面から Hermes のプロファイルを切り替える
公開サンプルです。`/friend` は気軽な会話、`/work` はファイル、検索、ツールを
使う作業向けです。

## インストール

まず Hermes をインストールし、2 つのプロファイルを作成します。

```bash
hermes profile create buddy-friend --no-skills
hermes profile create buddy-work
```

次に Buddy Switch をインストールします。

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

進行バーが完了すると、ターミナルの ASCII キャラクターが目を開き、初回設定が
始まります。プロファイル名と返信言語を選ぶと、編集用 SOUL 下書きが次の場所に
作成されます。

```text
~/.config/buddy-switch/personas/<profile-name>/SOUL.md
```

既存の Hermes `SOUL.md` は上書きされません。内容を確認してから手動で統合または
コピーしてください。

## Hermes の設定

両方の `config.yaml` に次の quick command を追加します。

```yaml
quick_commands:
  friend:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-friend"
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
```

gateway を再起動します。Telegram で `/friend` または `/work` を送り、10～20 秒
待ってから次のメッセージを送ります。

## ペルソナと言語

返信言語はルーティング設定ではなく、各プロファイルの `SOUL.md` に書く言語方針で
決まります。その言語が得意なモデルも選んでください。変更が反映されない場合は
新しい session を始めるか gateway を再起動してください。Hermes は agent や
session の間、system prompt を保持することがあります。

## サンプルと安全性

画像や `@mika`、`@forge` などの名前はルーティング例です。完成した 5 種類の
ペルソナは同梱されません。token、chat/user ID、個人パス、log、state DB、会話、
非公開 SOUL を commit しないでください。Telegram allowlist は placeholder で
共有してください。
