import Mix.Config

config :logger,
  backends: [:console],
  # backends: [case Mix.env do
  #     :host-> NVim.Logger
  #     :debug_host-> NVim.DebugLogger
  #     _-> :console
  # end],
  # level: if(Mix.env == :debug_host, do: :debug, else: :info),
  level: :debug,
  handle_otp_reports: true,
  handle_sasl_reports: true
