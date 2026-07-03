---
description: Gera daily standup em pt-BR com base nas tasks do Taskwarrior
---

Use a ferramenta `taskwarrior` para buscar:

1. Tarefas concluídas ontem: `all status:completed` — depois filtre pelo campo `Done` as tasks cujo valor de `Done` cai no dia de ontem (calendário, não janela de 24h — ou seja, qualquer horário do dia anterior à data atual)
2. Tarefas pendentes para hoje: `next`
3. Tarefas aguardando resposta/dependência: `all +wait status:pending` ou tasks com a tag `wait`

Com base no retorno, gere um **daily standup** em **português brasileiro (pt-BR)**, curto e direto, no formato:

**✅ O que fiz ontem:**

- lista das tasks concluídas (use a descrição da task, escrita de forma orientada a resultado)
- se não houver tasks concluídas, informe honestamente

**🔄 O que vou fazer hoje:**

- lista das tasks pendentes mais relevantes/urgentes (priorize por urgência e due date)

**⏳ Aguardando / Bloqueado:**

- lista das tasks com tag `wait`, descrevendo o que está sendo aguardado e de quem (use as anotações da task)
- se não houver nenhuma, omita este bloco completamente

**🚧 Impedimentos:**

- Nenhum _(deixe assim por padrão — o usuário edita se necessário)_

**Tom:** direto, sem rodeios. É para um time de engenharia de cloud.
**Idioma:** 100% português brasileiro.
**Formato:** texto simples, pronto para colar no Teams, Slack ou Jira.
