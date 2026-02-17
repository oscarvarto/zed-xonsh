# Xonsh extension for Zed

Point to an installation of [xonsh-language-server](https://github.com/FoamScience/xonsh-language-server) in your Zed's
`settings.json`:

```jsonc
lsp: {
  "xonsh-lsp": {
    "binary": {
      "path": "/path-to-your-pixi-env/.pixi/envs/default/bin/xonsh-lsp",
    },
    "initialization_options": {
      // You can choose a backend, like https://docs.astral.sh/ty/
      "pythonBackend": "ty",
    },
  },
}
```
