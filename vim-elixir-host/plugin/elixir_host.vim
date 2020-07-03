" let g:elixir_host_executable = globpath(&runtimepath, 'tools/nvim_elixir_host')
if !exists('g:elixir_host_executable')
  let g:elixir_host_executable = 'nvim_elixir_host'
endif

function! s:RequireElixirHost(host) abort
  let opts = {}
  let opts.rpc = v:true
  let cmd = g:elixir_host_executable

  if !executable(cmd)
    throw printf('Failed to start elixir-host: %s is not an executable', cmd)
  endif

  let channel_id = jobstart([cmd], opts)

  if channel_id == -1
    throw printf('Failed to start elixir-host: %s is not an executable', cmd)
  endif

  if channel_id == 0
    throw 'Failed to start elixir-host: invalid arguments'
  endif

  try
    if rpcrequest(channel_id, 'poll') ==# 'ok'
      return channel_id
    endif
  catch
    throw printf('Failed to start elixir-host: try running %s directly to verify that it works correctly', cmd)
  endtry
endfunction

call remote#host#Register('elixir', '*.e[zx]', function('s:RequireElixirHost'))
