-- Arquivo de carregamento automático para scrcpy.nvim
-- Este arquivo é opcional quando se usa Lazy.nvim com lazy-loading

-- Evita recarregar o plugin
if vim.g.loaded_scrcpy_nvim == 1 then
  return
end
vim.g.loaded_scrcpy_nvim = 1

-- Inicializa o plugin com configuração padrão
-- Isso é útil para usuários que não querem configurar o plugin manualmente
-- Os usuários ainda podem chamar setup() com suas próprias configurações
if not vim.g.scrcpy_nvim_disable_autosetup then
  require("scrcpy").setup({})
end

-- Define comandos
-- Isto é redundante se você estiver usando Lazy.nvim, pois os comandos já são definidos no setup()
-- Mas é útil para outros gerenciadores de plugins
vim.api.nvim_create_user_command("ScrcpyMirror", function()
  require("scrcpy").mirror()
end, {})

vim.api.nvim_create_user_command("ScrcpyRecordStart", function()
  require("scrcpy").record_start()
end, {})

vim.api.nvim_create_user_command("ScrcpyRecordStop", function()
  require("scrcpy").record_stop()
end, {})