# scrcpy.nvim

Plugin para Neovim que integra com o [scrcpy](https://github.com/Genymobile/scrcpy), permitindo espelhar e gravar a tela de dispositivos Android diretamente do editor.

## Requisitos

- Neovim 0.5.0+
- [scrcpy](https://github.com/Genymobile/scrcpy) instalado e acessível no PATH

## Instalação

### Usando [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  "seu-username/scrcpy.nvim",
  cmd = { "ScrcpyMirror", "ScrcpyRecordStart", "ScrcpyRecordStop" },
  config = function()
    require("scrcpy").setup({
      -- Configurações opcionais
      -- scrcpy_path = "caminho/para/scrcpy", -- Caminho personalizado para o executável scrcpy
      -- record_dir = "/caminho/personalizado", -- Diretório onde as gravações serão salvas
      -- notification_duration = 5000, -- Duração das notificações em ms
      -- default_options = {
      --   "--no-audio",
      --   "--stay-awake",
      --   -- Adicione outras opções padrão aqui
      -- },
    })
  end,
}
```

## Comandos

O plugin fornece os seguintes comandos:

- `:ScrcpyMirror` - Inicia o espelhamento da tela do dispositivo
- `:ScrcpyRecordStart` - Inicia o espelhamento e a gravação da tela do dispositivo
- `:ScrcpyRecordStop` - Para a gravação e o espelhamento, salvando o arquivo de vídeo

## Configuração

Você pode personalizar o comportamento do plugin durante a configuração:

```lua
require("scrcpy").setup({
  -- Caminho para o executável scrcpy (padrão: "scrcpy")
  scrcpy_path = "scrcpy",
  
  -- Diretório onde as gravações serão salvas (padrão: $HOME)
  record_dir = os.getenv("HOME"),
  
  -- Duração das notificações em ms (padrão: 3000)
  notification_duration = 3000,
  
  -- Opções padrão para o scrcpy
  default_options = {
    "--no-audio",       -- Desativa captura de áudio
    "--stay-awake",     -- Mantém o dispositivo acordado
    -- Adicione outras opções aqui
  },
})
```

## Uso

1. Conecte seu dispositivo Android via USB com a depuração USB ativada
2. Execute um dos comandos do plugin
3. Para interromper o espelhamento, feche a janela do scrcpy ou use `:ScrcpyRecordStop` se estiver gravando

## Solução de problemas

- Certifique-se de que o scrcpy está corretamente instalado e funcionando em seu sistema
- Verifique se o dispositivo está conectado e com a depuração USB ativada
- Se encontrar problemas, tente executar o scrcpy diretamente do terminal para verificar se há erros específicos

## Licença

MIT