defmodule MoveE2ETestTool.Tmp do
use ExUnit.Case
def run(agent) do
:persistent_term.put(:log,:nil)
:persistent_term.put(:log,:debug)
cmd=%{"args" => [],"cli" => "sui_client",
      "cmd" => "new-address"}
res=MoveE2ETestTool.CliParser.cmd(agent, cmd)
ignore_warn(res)
debug(cmd, res)
        expect = %{cli: :sui_client, cmd: :new_address}
        assert expect = cmd
        {:ok, %Web3MoveEx.Sui.Account{
         priv_key_base64: _,
        }} = res
        IO.inspect(res)
        :ok
end
def ignore_warn(_res), do: :ok 

    def debug(cmd, res) do
    case :persistent_term.get(:log) do
        :debug ->
              IO.puts(IO.ANSI.format([:blue, "===> #{inspect(cmd)}"]))
              IO.puts(IO.ANSI.format([:green, ".... #{inspect(res, pretty: true)}

"]))
         :ok
        :nil -> :ignore
    end
    end
    
end