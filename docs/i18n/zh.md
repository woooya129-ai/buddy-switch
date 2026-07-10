# Buddy Switch 中文指南

[英文主文档](../../README.md) · [角色与语言设置](../personas.md)

Buddy Switch 是一个公开示例，用于在同一个 Telegram 界面中切换 Hermes
配置文件。`/friend` 适合轻松聊天，`/work` 适合文件、搜索和工具任务。

## 安装

先安装 Hermes，并创建两个配置文件：

```bash
hermes profile create buddy-friend --no-skills
hermes profile create buddy-work
```

然后安装 Buddy Switch：

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

![在终端中运行的 Buddy Switch 安装程序](../../assets/buddy-switch-screenshot.png)

进度条完成后，终端中的 ASCII 角色会睁开眼睛，并启动首次设置。选择配置文件
名称和默认回复语言后，可编辑的 SOUL 草稿会生成在：

```text
~/.config/buddy-switch/personas/<配置文件名>/SOUL.md
```

安装程序不会覆盖现有的 Hermes `SOUL.md`。请先检查草稿，再手动合并或复制。

## Hermes 配置

将以下 quick command 添加到两个配置文件的 `config.yaml`：

```yaml
quick_commands:
  friend:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-friend"
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
```

重启 gateway，然后在 Telegram 中发送 `/friend` 或 `/work`。等待 10 到 20 秒，
再发送下一条消息。

## 角色与语言

回复语言由每个配置文件的 `SOUL.md` 语言规则决定，而不是 Buddy Switch 的路由
设置。还应选择擅长目标语言的模型。如果修改 SOUL 后没有生效，请开启新会话或
重启对应 gateway；Hermes 可能会缓存当前 agent 或 session 的系统提示词。

## 示例与安全

图片以及 `@mika`、`@forge` 等名称只是路由示例，并不代表仓库附带五个完整
角色。请勿提交 token、chat/user ID、本地路径、日志、state DB、聊天记录或
私人 SOUL。公开 Telegram allowlist 时请使用占位符。
