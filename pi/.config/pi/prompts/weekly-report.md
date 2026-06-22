---
description: Gera relatório semanal de tarefas concluídas para o gestor (em pt-BR)
argument-hint: "[semana: ex. 2026-06-16 até 2026-06-22]"
---

Use a ferramenta `taskwarrior` para buscar todas as tarefas com status `completed` encerradas nos últimos 7 dias. O comando base a usar é:

```
end.after:$(date -d '7 days ago' +%Y-%m-%d) status:completed list
```

Se um intervalo de datas específico foi fornecido como argumento (`$@`), use-o no lugar dos últimos 7 dias.

Com base nas tarefas retornadas, gere um **relatório semanal de atividades** em **português brasileiro (pt-BR)**, formatado para ser enviado diretamente ao gestor. O relatório deve:

1. Ter um cabeçalho com o período coberto (de segunda a sexta ou o intervalo real das tasks)
2. Agrupar as tarefas por projeto (campo `project` da task), se disponível
3. Para cada tarefa, descrever brevemente o que foi feito — use a descrição da task como base, mas escreva de forma profissional e orientada a resultado
4. Incluir uma seção de **destaques** se houver tarefas marcadas com prioridade `H`
5. Encerrar com um parágrafo curto de **próximos passos** baseado nas tarefas pendentes mais relevantes (use `taskwarrior` com `status:pending priority:H list` ou `next` para isso)

**Tom:** profissional, direto, sem exageros. É para um gestor de engenharia de cloud.
**Idioma:** 100% português brasileiro.
**Formato:** Markdown pronto para colar no Jira, e-mail ou Confluence.
