-- LuaSnip snippets for DevOps
return {
    'L3MON4D3/LuaSnip',
    config = function()
        local ls = require('luasnip')
        local s, t, i = ls.snippet, ls.text_node, ls.insert_node

        ls.add_snippets(nil, {
            terraform = {
                s('resource', { t('resource "'), i(1, 'type'), t('" "'), i(2, 'name'), t('" {\n  '), i(0), t('\n}') }),
                s('provider', { t('provider "'), i(1, 'name'), t('" {\n  '), i(0), t('\n}') }),
            },
            sh = {
                s('shebang', { t({ '#!/bin/bash', 'set -euo pipefail', '', '' }) }),
                s('func', { t('function '), i(1, 'name'), t('() {\n  '), i(0), t('\n}') }),
            },
            dockerfile = {
                s('base', { t('FROM '), i(1, 'alpine:latest') }),
                s('run', { t('RUN '), i(0) }),
            },
            yaml = {
                s('k8sdeploy', {
                    t({ 'apiVersion: apps/v1', 'kind: Deployment', 'metadata:', '  name: ' }), i(1, 'app'),
                    t({ '', 'spec:', '  replicas: ' }), i(2, '1'),
                    t({ '', '  selector:', '    matchLabels:', '      app: ' }), i(3, 'app'),
                    t({ '', '  template:', '    metadata:', '      labels:', '        app: ' }), i(4, 'app'),
                    t({ '', '    spec:', '      containers:', '      - name: ' }), i(5, 'app'),
                    t({ '', '        image: ' }), i(0, 'image:tag'),
                }),
            },
            python = {
                s('func', { t('def '), i(1, 'func'), t('('), i(2), t('):\n    '), i(0, 'pass') }),
                s('class', { t('class '), i(1, 'Class'), t(':\n    def __init__(self):\n        '), i(0, 'pass') }),
            },
        })
    end,
}
