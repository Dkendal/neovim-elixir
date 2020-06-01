defmodule NVim.Api do
  @moduledoc """
    Auto generate the NVim module with functions extracted from the spec
    available either globally using `nvim --api-info` or once an instance is
    attached with the `vim_get_api_info` internal cmd.
  """

  def from_cmd do
    case System.cmd("nvim", ["--api-info"]) do
      {res, 0} ->
        {:ok, spec} = MessagePack.unpack(res)
        generate_neovim(spec)

      _ ->
        :ok
    end
  end

  def from_instance do
    {:ok, [_, spec]} = GenServer.call(NVim.Link, {"vim_get_api_info", []})
    generate_neovim(spec)
  end

  ## HACK TO ENSURE that Vim function name IS NOT a reserved elixir keyword
  def map_vimname(:fn), do: :fun
  def map_vimname(param), do: param

  def vim_type("Buffer"), do: {:nvim_buffer, [], Elixir}
  def vim_type("Window"), do: {:nvim_window, [], Elixir}
  def vim_type("Tabpage"), do: {:nvim_tab_page, [], Elixir}
  def vim_type("Float"), do: {:float, [], Elixir}
  def vim_type("Integer"), do: {:integer, [], Elixir}
  def vim_type("Boolean"), do: {:boolean, [], Elixir}
  def vim_type("Dictionary"), do: {:map, [], Elixir}
  def vim_type("Array"), do: {:list, [], Elixir}
  def vim_type("String"), do: quote(do: String.t())
  def vim_type("Object"), do: {:any, [], Elixir}
  def vim_type("void"), do: {:none, [], Elixir}

  def vim_type("ArrayOf(" <> term) do
    tokens =
      term
      |> String.split([",", ")", " "])
      |> Enum.filter(&is_nil/1)

    vim_type(:array, tokens)
  end

  def vim_type(:array, []), do: :list

  def vim_type(:array, [type, ""]) do
    inner_type = vim_type(type)
    quote(do: list(unquote(inner_type)))
  end

  def vim_type(:array, [type, size]) do
    inner_type = vim_type(type)
    for _ <- 0..size, do: inner_type
  end

  def generate_neovim(%{"functions" => fns, "types" => types}) do
    defmodule Elixir.NVim do
      @opaque nvim_buffer :: integer()
      @opaque nvim_tab_page :: integer()
      @opaque nvim_window :: integer()

      Enum.each(fns, fn %{"name" => name, "parameters" => params} = func ->
        fnparams =
          for [type, pname] <- params do
            quote do
              var!(unquote({NVim.Api.map_vimname(:"#{pname}"), [], Elixir}))
            end
          end

        # Generate arguments for the function spec
        spec_args =
          for [type, name] <- params do
            quote(do: unquote({NVim.Api.map_vimname(:"#{name}"), [], Elixir}) :: unquote(NVim.Api.vim_type(type)))
          end

        spec_return_value = NVim.Api.vim_type(func["return_type"])

        spec =
          quote do
            @spec unquote(:"#{name}")(unquote_splicing(spec_args)) :: unquote(spec_return_value)
          end

        @doc """
          Parameters : #{inspect(params)}

          Return : #{inspect(func["return_type"])}

          This function can #{if func["can_fail"] != true, do: "not "}fail

          This function can #{if func["deferred"] != true, do: "not "}be deferred
        """
        Module.eval_quoted(
          NVim,
          quote do
            unquote(spec)

            def unquote(:"#{name}")(unquote_splicing(fnparams)) do
              GenServer.call(NVim.Link, {unquote("#{name}"), unquote(fnparams)}, :infinity)
            end
          end
        )
      end)
    end

    Enum.each(types, fn {name, %{"id" => _id}} ->
      defmodule Module.concat(["Elixir", "NVim", name]) do
        defstruct content: ""
      end
    end)

    defmodule Elixir.NVim.Ext do
      use MessagePack.Ext.Behaviour

      Enum.each(types, fn {name, %{"id" => id}} ->
        Module.eval_quoted(
          NVim.Ext,
          quote do
            def pack(%unquote(Module.concat(["NVim", name])){content: bin}), do: {:ok, {unquote(id), bin}}
          end
        )
      end)

      Enum.each(types, fn {name, %{"id" => id}} ->
        Module.eval_quoted(
          NVim.Ext,
          quote do
            def unpack(unquote(id), bin), do: {:ok, %unquote(Module.concat(["NVim", name])){content: bin}}
          end
        )
      end)
    end
  end
end

NVim.Api.from_cmd()
