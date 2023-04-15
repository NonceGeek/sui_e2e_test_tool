defmodule MoveE2ETestTool.CliParser do
  alias Web3MoveEx.Sui
  import NimbleParsec

  @moduledoc """
    aptos CLI commands:
      $ aptos move init
  """

  def start() do
    {:ok, client} = Sui.RPC.connect()
    Agent.start_link fn -> %{client: client} end
  end
  def start(client) do
    Agent.start_link fn -> %{client: client} end
  end

  def cmd(agent, "sui client new-address secp256k1") do
    {:ok, acct} = Web3MoveEx.Sui.gen_acct()
    {:ok, acct} =
      {:ok,
      %Web3MoveEx.Sui.Account{
        sui_address: <<173, 247, 138, 113, 25, 16, 185, 209, 222, 3, 2, 38, 31, 18,
          48, 156, 136, 2, 245, 243, 0, 205, 170, 16, 200, 119, 17, 120, 234, 150,
          208, 145>>,
        sui_address_hex: "0xadf78a711910b9d1de0302261f12309c8802f5f300cdaa10c8771178ea96d091",
        priv_key: <<0, 11, 166, 31, 134, 41, 92, 19, 157, 130, 92, 13, 61, 169, 69,
          25, 184, 250, 110, 217, 83, 192, 231, 128, 112, 2, 108, 115, 39, 229, 224,
          14, 7>>,
        priv_key_base64: "AAumH4YpXBOdglwNPalFGbj6btlTwOeAcAJscyfl4A4H",
        key_schema: "ed25519",
        phrase: "city record reject glow similar misery finger tongue wage diesel high prevent end gadget pill tiny shine muffin prefer coffee custom shell quantum office"
    }}
    Agent.update(agent, fn dict ->
      Map.put(dict, :acct, acct)
    end)
    {:ok, acct}
  end

  def cmd(agent, "sui client gas") do
    %{client: client, acct: acct} =
      Agent.get(agent, fn state -> state end)
    {:ok,
      %{data: data}
    } =
    Web3MoveEx.Sui.get_all_coins(client, acct.sui_address_hex)
    data
  end

  @doc """
    "sui client transfer-sui --to 0x181bd292dbe70628479b85e873460caa3e180fe2 --sui-coin-object-id 0x82db13db77f034873cf3f1f2e43fc1237e08664e --gas-budget 30000"
  """
  def cmd(agent, other_cmds) do
    %{client: client, acct: acct} =
      Agent.get(agent, fn state -> state end)

    case String.split_at(other_cmds, 24) do
      {"sui client transfer-sui ", others} ->
        ["--to", to_addr, "--sui-coin-object-id",
        obj_id, "--gas-budget", gas] =
          String.split(others, " ")
      Sui.transfer(client, acct, obj_id, gas, to_addr)
      others ->
        :not_transfer
    end

  end
  # aptos_signal =
  #   string("aptos")

  # aptos_move_signal =
  #   string("aptos move")
  # space = ascii_string([?\s], min: 0) |> ignore()
  # name_param_signal =
  #   string("--name")
  #   |> ignore(space)
  #   |> concat(ascii_string([?_, ?0..?9, ?a..?z, ?A..?Z], min: 0))

  # buzz_param_signal =
  #   string("--buzz")
  #   |> ignore(space)
  #   |> concat(ascii_string([?_, ?0..?9, ?a..?z, ?A..?Z], min: 0))

  # defparsec :cmd,
  #   choice([
  #     aptos_move_signal,
  #     aptos_signal
  #   ])
  #   |> ignore(space)
  #   |> choice([
  #     string("init"),
  #     string("e2e_test")
  #   ])
  #   |> ignore(space)

  # defparsec :params,
  #   optional(name_param_signal)
  #   |> ignore(space)
  #   |> optional(buzz_param_signal)

  # def parse_cmd(cmd_str) do
  #   IO.puts inspect cmd(cmd_str)
  #   with {:ok, result, params, _, _, _} <- cmd(cmd_str) do
  #     {[first_arg], behaviour} = Enum.split(result, 1)
  #     do_parse_cmd(first_arg, behaviour, params)
  #   end
  # end

  # def do_parse_cmd("aptos", behaviour, params), do: handle_aptos(behaviour, params)
  # def do_parse_cmd("aptos move", behaviour, params), do: handle_aptos_move(behaviour, params)

  # def handle_aptos(_behaviour, _params) do
  #   :aptos
  # end

  # def handle_aptos_move(["init"], params) do
  #   with {:ok, params_list, _, _, _, _} <- params(params) do
  #     :init
  #   end

  # end

  # def handle_aptos_move(["e2e_test"], params) do
  #   :e2e_test
  # end

  # def handle_aptos_move(others) do
  #   others
  # end
end
