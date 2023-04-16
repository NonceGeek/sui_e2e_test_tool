defmodule MoveE2ETestTool.SuiCliParser do
  import NimbleParsec
  space = ascii_string([?\s], min: 0) |> ignore()
  fun = ascii_string([?_, ?a..?z, ?A..?Z], min: 1)
  module = ascii_string([?_, ?a..?z, ?A..?Z], min: 1)
  package = ascii_string([?_, ?0..?9, ?a..?z, ?A..?Z], min: 1)
  args = ascii_string([?_, ?0..?9, ?a..?z, ?A..?Z], min: 1)
  obj = ascii_string([?_, ?0..?9, ?a..?z, ?A..?Z], min: 1)
  priv = ascii_string([?/, ?+, ?0..?9, ?a..?z, ?A..?Z], min: 44)
  number = integer(min: 1, max: 20)
  address = ascii_string([?0..?9, ?a..?z, ?A..?Z], min: 66)

  call_options =
    choice([
      string("--function")
      |> ignore()
      |> concat(space)
      |> concat(fun)
      |> unwrap_and_tag(:function)
      |> label("function"),
      string("--module")
      |> ignore()
      |> concat(space)
      |> concat(module)
      |> unwrap_and_tag(:module)
      |> label("module"),
      string("--package")
      |> ignore()
      |> concat(space)
      |> concat(package)
      |> unwrap_and_tag(:package)
      |> label("package"),
      string("--args")
      |> ignore()
      |> concat(repeat(space |> concat(args)))
      |> tag(:args)
      |> label("args"),
      string("--gas")
      |> ignore()
      |> concat(space)
      |> concat(obj)
      |> unwrap_and_tag(:gas)
      |> label("gas"),
      string("--gas-budget")
      |> ignore()
      |> concat(space)
      |> concat(number)
      |> unwrap_and_tag(:gas_budget)
      |> label("gas_budget")
    ])

  call =
    string("call")
    |> replace(:call)
    |> unwrap_and_tag(:cmd)
    |> repeat(space |> concat(call_options))
    |> label("call")

  gas = string("gas") |> replace(:gas) |> unwrap_and_tag(:cmd)

  import_address =
    choice([string("import_address"), string("import-address")])
    |> replace(:import_address)
    |> unwrap_and_tag(:cmd)
    |> concat(repeat(space |> concat(priv)) |> tag(:priv))
    |> label("import_address")

    transfer_sui_options = choice([
      string("--to")  |> ignore() |> concat(space) |> concat(address) |> unwrap_and_tag(:to),
      string("--sui-coin-object-id") |> ignore() |> concat(space) |> concat(obj) |> unwrap_and_tag(:sui_coin_object_id),
      string("--gas-budget") |> ignore() |> concat(space) |> concat(number) |> unwrap_and_tag(:gas_budget)
    ])

    transfer_sui = choice([string("transfer-sui"), string("transfer_sui")]) |>
    replace(:transfer_sui) |> unwrap_and_tag(:cmd)
    |> repeat( space |> concat(transfer_sui_options))
    |> label("transfer_sui")

  key_schema =
    choice([
      string("secp256k1"),
      string("ed25519"),
      string("secp256r1")
    ])
    |> label("choice key_schema")

  new_address =
    string("new-address")
    |> replace(:new_address)
    |> unwrap_and_tag(:cmd)
    |> optional(
      space
      |> concat(key_schema)
      |> unwrap_and_tag(:key_schema)
    )
    |> label("new_address command")

  sui_client_signal =
    string("sui client")
    |> replace(:sui_client)
    |> unwrap_and_tag(:cli)
    |> concat(space)
    |> choice([
      new_address,
      call,
      gas,
      import_address,
      transfer_sui
    ])
    |> label("sui_client_signal")

  assert_signal = string("assert") |> label("assert command")
  space = ascii_string([?\s], min: 0) |> ignore()

  name_param_signal =
    string("--name")
    |> ignore(space)
    |> concat(ascii_string([?_, ?0..?9, ?a..?z, ?A..?Z], min: 0))
  code =
  defparsec(
    :cmd,
#    choice([
      sui_client_signal
#      assert_signal
#    ])
  )

  def parse_script(str) do
    String.split(str, "\n")
    |> Enum.map(fn x -> String.trim(x) end)
    |> Enum.filter(fn x -> ignore_comment_line(x) end)
    |> Enum.map(&parse_cmd/1)
  end

  def ignore_comment_line("") do
    false
  end

  def ignore_comment_line("#" <> _) do
    false
  end

  def ignore_comment_line(_) do
    true
  end

  def parse_cmd(cmd_str) do
    with {:ok, result, _, _, _, _} <- cmd(cmd_str) do
      result |> Enum.into(%{})
      else
      {:error, "expected sui_client_signal", line, %{}, {1, 0}, 0} ->
      %{cli: :code, line: line}
    end
  end
end
