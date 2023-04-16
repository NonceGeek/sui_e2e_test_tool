defmodule MoveE2ETestTool.CliParser do
  alias Web3MoveEx.Sui
  alias MoveE2ETestTool.SuiCliParser

  @moduledoc """
  """
  def run(script) do
      code =  SuiCliParser.parse_script(script)
       |> List.foldl("defmodule MoveE2ETestTool.Tmp do\nuse ExUnit.Case\ndef run(agent) do\n", &gen_code/2)
       code = code <>  "\nend\nend"
       Code.eval_string(code)
      {:ok, agent} = start()
       MoveE2ETestTool.Tmp.run(agent)
    end
  def gen_code(%{cli: :sui_client} = cmd, acc)  do
       acc <> "\n
       cmd = #{inspect(cmd)}\n
       res = MoveE2ETestTool.CliParser.cmd(agent, #{inspect(cmd)})\n"
  end
  def gen_code(%{cli: :code, line: line} = cmd, acc)  do
       acc <> line <> "\n"
  end
  def start() do
    {:ok, client} = Sui.RPC.connect()
    Agent.start_link(fn -> %{client: client} end)
  end

  def start(client) do
    Agent.start_link(fn -> %{client: client} end)
  end

  def cmd(agent, %{cli: :sui_client, cmd: :new_address, key_schema: key_schema}) do
    {:ok, acct} = Web3MoveEx.Sui.gen_acct(String.to_atom(key_schema))
    {:ok, acct} =
      {:ok,
       %Web3MoveEx.Sui.Account{
         sui_address:
           <<173, 247, 138, 113, 25, 16, 185, 209, 222, 3, 2, 38, 31, 18, 48, 156, 136, 2, 245,
             243, 0, 205, 170, 16, 200, 119, 17, 120, 234, 150, 208, 145>>,
         sui_address_hex: "0xadf78a711910b9d1de0302261f12309c8802f5f300cdaa10c8771178ea96d091",
         priv_key:
           <<0, 11, 166, 31, 134, 41, 92, 19, 157, 130, 92, 13, 61, 169, 69, 25, 184, 250, 110,
             217, 83, 192, 231, 128, 112, 2, 108, 115, 39, 229, 224, 14, 7>>,
         priv_key_base64: "AAumH4YpXBOdglwNPalFGbj6btlTwOeAcAJscyfl4A4H",
         key_schema: "ed25519",
         phrase:
           "city record reject glow similar misery finger tongue wage diesel high prevent end gadget pill tiny shine muffin prefer coffee custom shell quantum office"
       }}

    Agent.update(agent, fn dict ->
      Map.put(dict, :acct, acct)
    end)

    {:ok, acct}
  end

  def cmd(agent, %{cli: :sui_client, cmd: :new_address}) do
      cmd(agent, %{cli: :sui_client, cmd: :new_address, key_schema: "ed25519"})
   end
  def cmd(agent, %{cli: :sui_client, cmd: :gas}) do
    %{client: client, acct: acct} = Agent.get(agent, fn state -> state end)
    {:ok, %{data: data}} = Web3MoveEx.Sui.get_all_coins(client, acct.sui_address_hex)
    data
  end
  def cmd(agent, %{
             :cli => :sui_client,
             :cmd => :call,
             :package => package,
             :function => function,
             :module => module,
             :args => args,
             :gas => gas,
             :gas_budget => gas_budget
           }) do
    %{client: client, acct: acct} = Agent.get(agent, fn state -> state end)
   client |> Sui.move_call(acct, package, module, function, [], args, gas, gas_budget)
  end
def cmd(agent, %{
             :cli => :sui_client,
             :cmd => :call,
             :package => package,
             :function => function,
             :module => module,
             :args => args,
             :gas_budget => gas_budget
           } = params) do
   cmd(agent, Map.put(params, :gas, nil))
  end
  @doc """
    "sui client transfer-sui --to 0x181bd292dbe70628479b85e873460caa3e180fe2 --sui-coin-object-id 0x82db13db77f034873cf3f1f2e43fc1237e08664e --gas-budget 30000"
  """
  def cmd(agent, %{
             cli: :sui_client,
             cmd: :transfer_sui,
             gas_budget: gas_budget,
             sui_coin_object_id: sui_coin_object_id,
             to: to
           }) do
    %{client: client, acct: acct} = Agent.get(agent, fn state -> state end)
     Sui.unsafe_transfer(client, acct, sui_coin_object_id, gas_budget, to)
  end
end
