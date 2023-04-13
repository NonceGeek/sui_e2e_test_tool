defmodule MoveE2eTestTool.CliParser do
  import NimbleParsec

  @moduledoc """
    aptos CLI commands:
      $ aptos move init
  """

  aptos_signal =
    string("aptos")

  aptos_move_signal =
    string("aptos move")
  space = ascii_string([?\s], min: 0) |> ignore()
  name_param_signal =
    string("--name")
    |> ignore(space)
    |> concat(ascii_string([?_, ?0..?9, ?a..?z, ?A..?Z], min: 0))

  buzz_param_signal =
    string("--buzz")
    |> ignore(space)
    |> concat(ascii_string([?_, ?0..?9, ?a..?z, ?A..?Z], min: 0))

  defparsec :cmd,
    choice([
      aptos_move_signal,
      aptos_signal
    ])
    |> ignore(space)
    |> choice([
      string("init"),
      string("e2e_test")
    ])
    |> ignore(space)

  defparsec :params,
    optional(name_param_signal)
    |> ignore(space)
    |> optional(buzz_param_signal)

  def parse_cmd(cmd_str) do
    IO.puts inspect cmd(cmd_str)
    with {:ok, result, params, _, _, _} <- cmd(cmd_str) do
      {[first_arg], behaviour} = Enum.split(result, 1)
      do_parse_cmd(first_arg, behaviour, params)
    end
  end

  def do_parse_cmd("aptos", behaviour, params), do: handle_aptos(behaviour, params)
  def do_parse_cmd("aptos move", behaviour, params), do: handle_aptos_move(behaviour, params)

  def handle_aptos(_behaviour, _params) do
    :aptos
  end

  def handle_aptos_move(["init"], params) do
    with {:ok, params_list, _, _, _, _} <- params(params) do
      :init
    end

  end

  def handle_aptos_move(["e2e_test"], params) do
    :e2e_test
  end

  def handle_aptos_move(others) do
    others
  end
end
