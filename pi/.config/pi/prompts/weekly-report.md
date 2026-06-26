---
description: Resumo semanal de tarefas concluídas, agrupado por projeto (pt-BR)
argument-hint: "[data de início da semana: ex. 2026-06-22]"
---

Use a ferramenta `taskwarrior` para buscar todas as tarefas concluídas na semana atual com o comando:

```
task completed end.after:<segunda-feira da semana atual>
```

Se uma data de início for fornecida como argumento (`$@`), use-a no lugar da data calculada.

Com base nas tarefas retornadas:

1. **Agrupe por projeto** (campo `project`).
2. **Para cada projeto**, escreva um parágrafo curto descrevendo o que foi feito — use as descrições das tasks como base, mas escreva de forma profissional e orientada a resultado.
3. **Cabeçalho** com o período coberto (ex: "22 a 26 Jun 2026").
4. **Rodapé** com o total de tarefas concluídas na semana.

**Tom:** profissional, direto, sem exageros. É para um Cloud Engineer refletir sobre a própria semana.
**Idioma:** 100% português brasileiro.
**Formato:** Markdown limpo.
