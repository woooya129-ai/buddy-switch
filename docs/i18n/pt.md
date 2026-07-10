# Guia do Buddy Switch em português

[README principal em inglês](../../README.md) · [Personas e idiomas](../personas.md)

Buddy Switch é um exemplo público para alternar perfis do Hermes na mesma
conversa do Telegram. `/friend` serve para conversa leve e `/work` para
arquivos, pesquisa e ferramentas.

## Instalação

Instale o Hermes e crie dois perfis:

```bash
hermes profile create buddy-friend --no-skills
hermes profile create buddy-work
```

Depois instale o Buddy Switch:

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

Ao terminar a barra de progresso, a personagem ASCII do terminal abre os olhos
e a configuração inicial começa. Depois de escolher os nomes e o idioma, são
criados rascunhos SOUL editáveis em:

```text
~/.config/buddy-switch/personas/<nome-do-perfil>/SOUL.md
```

O instalador nunca sobrescreve um `SOUL.md` do Hermes. Revise o rascunho antes
de copiar ou mesclar.

## Configuração do Hermes

Adicione este bloco ao `config.yaml` dos dois perfis:

```yaml
quick_commands:
  friend:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-friend"
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
```

Reinicie o gateway. No Telegram, envie `/friend` ou `/work`, espere de 10 a 20
segundos e envie a próxima mensagem.

## Persona e idioma

O idioma de resposta é definido pela política de idioma no `SOUL.md` de cada
perfil, não pelo roteamento. Escolha também um modelo competente nesse idioma.
Se uma edição não aparecer, inicie uma nova sessão ou reinicie o gateway, pois
o Hermes pode manter o prompt do sistema durante o agent ou a session.

## Exemplos e segurança

As imagens e nomes como `@mika` e `@forge` são exemplos de rotas; o repositório
não inclui cinco personas prontas. Não publique tokens, IDs de chat ou usuário,
caminhos privados, logs, state DB, conversas ou SOUL privados. Use placeholders
ao compartilhar allowlists do Telegram.
