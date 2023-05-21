defmodule MoveE2ETestTool.SuiClient do
use ExUnit.Case
def run(agent) do
:persistent_term.put(:log,:nil)
:persistent_term.put(:log,:debug)
cmd=%{"args" => ["secp256k1"],
      "cli" => "sui_client","cmd" => "new-address"}
res=MoveE2ETestTool.CliParser.cmd(agent, cmd)
ignore_warn(res)
debug(cmd, res)
    # 导入一个已有地址
    # 执行 ex 特有的 script
cmd=%{"args" => ["AAumH4YpXBOdglwNPalFGbj6btlTwOeAcAJscyfl4A4H"],
      "cli" => "sui_client","cmd" => "import-address"}
res=MoveE2ETestTool.CliParser.cmd(agent, cmd)
ignore_warn(res)
debug(cmd, res)
    # ex_script: set contract [contract_addr_str]
    # 查看已有地址的 gas 费用
cmd=%{"cli" => "sui_client","cmd" => "gas"}
res=MoveE2ETestTool.CliParser.cmd(agent, cmd)
ignore_warn(res)
debug(cmd, res)
    # buy_bread
    # sui client call --function buy_bread --module sandwich --package 0x08204ed92afcfdf9d0f6727a2c7d40db93a059d8 --args args1 args2 --gas-budget 30000
    # check if there is a bread
    # // TODO
    # buy_ham
    # sui client call --function buy_ham --module sandwich --package 0x08204ed92afcfdf9d0f6727a2c7d40db93a059d8 --args args1 args2 --gas gas_obj --gas-budget 30000
    # check if there is a ham
    # a=:a
    assert res == []
    #
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