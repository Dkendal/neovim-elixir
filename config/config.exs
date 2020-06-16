use Mix.Config

config :logger,
  backends: [{ LoggerFileBackend, :file }],
  # backends: [case Mix.env do
  #     :host-> NVim.Logger
  #     :debug_host-> NVim.DebugLogger
  #     _-> :console
  # end],
  # level: if(Mix.env == :debug_host, do: :debug, else: :info),
  level: :debug,
  handle_otp_reports: true,
  handle_sasl_reports: true

  config :logger, :file,
    path: "/tmp/nvim_debug.log"

config :neovim,
  debug_logger_file: "/tmp/nvim_debug.log",
  update_api_on_startup: true,
  link: :stdio
  # link: if(Mix.env in [:host,:debug_host], 
  #         do: :stdio,
  #         else: {:tcp,"127.0.0.1",6666})

config :ex_unit, timeout: :infinity

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
