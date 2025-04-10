-- scrcpy.nvim
-- Plugin para integração do scrcpy com o Neovim
-- Autor: Claude

local M = {}

-- Configurações padrão
M.config = {
  scrcpy_path = "scrcpy",
  record_dir = os.getenv("HOME"),
  notification_duration = 3000, -- tempo em ms
  default_options = {
    "--no-audio", -- desativa captura de áudio por padrão
    "--stay-awake", -- mantém o dispositivo acordado
  },
}

-- Variáveis de estado global
local state = {
  is_mirroring = false,
  is_recording = false,
  job_id = nil,
  current_recording_file = nil,
  notification_timer = nil,
}

-- Função para mostrar notificações
local function notify(msg, level)
  level = level or vim.log.levels.INFO
  
  -- Limpar notificação anterior se existir
  if state.notification_timer then
    vim.fn.timer_stop(state.notification_timer)
    state.notification_timer = nil
  end
  
  -- Mostrar notificação
  vim.notify(msg, level, {
    title = "scrcpy.nvim",
  })
  
  -- Configurar temporizador para limpar a notificação
  state.notification_timer = vim.fn.timer_start(
    M.config.notification_duration,
    function() vim.cmd("echon ''") end
  )
end

-- Função para verificar se o scrcpy está instalado
local function check_scrcpy()
  local handle = io.popen("command -v " .. M.config.scrcpy_path)
  local result = handle:read("*a")
  handle:close()
  
  if result == "" then
    notify("scrcpy não encontrado. Verifique se está instalado.", vim.log.levels.ERROR)
    return false
  end
  
  return true
end

-- Função para construir o comando scrcpy com as opções
local function build_command(options)
  local cmd = M.config.scrcpy_path
  
  -- Adicionar opções padrão
  for _, opt in ipairs(M.config.default_options) do
    cmd = cmd .. " " .. opt
  end
  
  -- Adicionar opções específicas
  if options then
    for _, opt in ipairs(options) do
      cmd = cmd .. " " .. opt
    end
  end
  
  return cmd
end

-- Função para parar o processo atual
local function stop_current_process()
  if state.job_id then
    vim.fn.jobstop(state.job_id)
    state.job_id = nil
  end
  
  state.is_mirroring = false
  state.is_recording = false
end

-- Função para iniciar o espelhamento
function M.mirror()
  if state.is_mirroring then
    notify("Já existe um espelhamento em execução", vim.log.levels.WARN)
    return
  end
  
  if not check_scrcpy() then
    return
  end
  
  local cmd = build_command({})
  
  notify("Iniciando espelhamento do dispositivo...")
  
  -- Iniciar processo em background
  state.job_id = vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        notify("Espelhamento encerrado com erro: " .. exit_code, vim.log.levels.ERROR)
      else
        notify("Espelhamento encerrado")
      end
      state.is_mirroring = false
      state.job_id = nil
    end
  })
  
  if state.job_id <= 0 then
    notify("Falha ao iniciar espelhamento", vim.log.levels.ERROR)
    return
  end
  
  state.is_mirroring = true
end

-- Função para iniciar gravação
function M.record_start()
  if state.is_recording then
    notify("Já existe uma gravação em execução", vim.log.levels.WARN)
    return
  end
  
  if not check_scrcpy() then
    return
  end
  
  -- Parar processo atual se estiver rodando
  if state.is_mirroring then
    stop_current_process()
  end
  
  -- Gerar nome do arquivo de gravação
  local timestamp = os.date("%Y%m%d_%H%M%S")
  local filename = "scrcpy_record_" .. timestamp .. ".mp4"
  local filepath = M.config.record_dir .. "/" .. filename
  state.current_recording_file = filepath
  
  local cmd = build_command({
    "--record=" .. filepath,
    "--show-touches", -- mostra toques na tela durante a gravação
  })
  
  notify("Iniciando espelhamento e gravação do dispositivo...")
  
  -- Iniciar processo em background
  state.job_id = vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        notify("Gravação encerrada com erro: " .. exit_code, vim.log.levels.ERROR)
      else
        if state.is_recording then
          notify("Gravação salva em: " .. state.current_recording_file)
        end
      end
      state.is_mirroring = false
      state.is_recording = false
      state.job_id = nil
    end
  })
  
  if state.job_id <= 0 then
    notify("Falha ao iniciar gravação", vim.log.levels.ERROR)
    return
  end
  
  state.is_mirroring = true
  state.is_recording = true
end

-- Função para parar gravação
function M.record_stop()
  if not state.is_recording then
    notify("Não há gravação em andamento", vim.log.levels.WARN)
    return
  end
  
  notify("Parando gravação e salvando arquivo...")
  stop_current_process()
end

-- Configuração do plugin
function M.setup(opts)
  -- Mesclar configurações do usuário com as padrões
  if opts then
    M.config = vim.tbl_deep_extend("force", M.config, opts)
  end
  
  -- Definir comandos Vim
  vim.api.nvim_create_user_command("ScrcpyMirror", function()
    M.mirror()
  end, {})
  
  vim.api.nvim_create_user_command("ScrcpyRecordStart", function()
    M.record_start()
  end, {})
  
  vim.api.nvim_create_user_command("ScrcpyRecordStop", function()
    M.record_stop()
  end, {})
end

return M