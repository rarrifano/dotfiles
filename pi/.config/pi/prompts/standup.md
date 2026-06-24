---
description: Gera daily standup em pt-BR com base nas tasks do Taskwarrior
---

Use a ferramenta `taskwarrior` para buscar:

1. Tarefas concluídas ontem: `all status:completed` — depois filtre pelo campo `Done` as tasks concluídas nas últimas 24h
2. Tarefas pendentes para hoje: `next`

Com base no retorno, gere um **daily standup** em **português brasileiro (pt-BR)**, curto e direto, no formato:

**✅ O que fiz ontem:**
- lista das tasks concluídas (use a descrição da task, escrita de forma orientada a resultado)
- se não houver tasks concluídas, informe honestamente

**🔄 O que vou fazer hoje:**
- lista das tasks pendentes mais relevantes/urgentes (priorize por urgência e due date)

**🚧 Impedimentos:**
- Nenhum *(deixe assim por padrão — o usuário edita se necessário)*

**Tom:** direto, sem rodeios. É para um time de engenharia de cloud.
**Idioma:** 100% português brasileiro.
**Formato:** texto simples, pronto para colar no Teams, Slack ou Jira.
