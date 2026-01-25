-- Luasnip basic DevOps snippets (Terraform, Bash, Dockerfile, K8s YAML, Python)
local ls = require'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets(nil, {
  terraform = {
    s("resource", {
      t('resource "'), i(1, "type"), t('" "'), i(2, "name"), t('" {\n  '), t('\n}'),
    }),
    s("provider", {
      t('provider "'), i(1, "name"), t('" {\n  '), t('\n}'),
    })
  },
  sh = {
    s("shebang", { t("#!/bin/bash\nset -e\n") }),
    s("func", { t("function "), i(1, "name"), t("() {\n  "), i(2), t("\n}\n") })
  },
  dockerfile = {
    s("base", { t("FROM "), i(1, "alpine:latest") }),
    s("run", { t("RUN "), i(1, "echo Hello") })
  },
  yaml = {
    s("k8sdeploy", {
      t({'apiVersion: apps/v1', 'kind: Deployment', 'metadata:', '  name: '}), i(1, "name"),
      t({'', 'spec:', '  replicas: '}), i(2, "1"),
      t({'', '  template:', '    metadata:', '      labels:', '        app: '}), i(3, "label"),
      t({'', '    spec:', '      containers:', '      - name: '}), i(4, "container"),
      t({'', '        image: '}), i(5, "image:tag"), t({''}),
    })
  },
  python = {
    s("func", {
      t("def "), i(1, "function_name"), t("():\n    "), i(2, "pass")
    }),
    s("class", {
      t("class "), i(1, "ClassName"), t(":\n    def __init__(self):\n        "), i(2, "pass")
    })
  },
})
