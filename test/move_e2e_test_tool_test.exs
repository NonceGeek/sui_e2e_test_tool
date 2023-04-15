defmodule MoveE2ETestToolTest do
  use ExUnit.Case
  doctest MoveE2ETestTool

  test "parse script" do
    assert [
             %{cli: :sui_client, cmd: :new_address, key_schema: "secp256k1"},
             %{
               cli: :sui_client,
               cmd: :import_address,
               priv: "AKpjfApmHx8FbjrRRSrUlF6ITigjP8NMS1ip4JdqPp5g"
             },
             %{cli: :sui_client, cmd: :gas},
             %{
               :args => ["args1", "args2"],
               :cli => :sui_client,
               :cmd => :call,
               :function => "buy_bread",
               :gas => "gas_obj",
               :module => "sandwich",
               :package => "0x08204ed92afcfdf9d0f6727a2c7d40db93a059d8",
               :gas_budget => 30000
             },
             %{
               :args => ["args1", "args2"],
               :cli => :sui_client,
               :cmd => :call,
               :function => "buy_ham",
               :gas => "gas_obj",
               :module => "sandwich",
               :package => "0x08204ed92afcfdf9d0f6727a2c7d40db93a059d8",
               :gas_budget => 30000
             }
           ] = MoveE2ETestTool.SuiCliParser.parse_script(script())
  end

  test "sui client import_address" do
    assert %{
             cli: :sui_client,
             cmd: :import_address,
             priv: "AKpjfApmHx8FbjrRRSrUlF6ITigjP8NMS1ip4JdqPp5g"
           } =
             MoveE2ETestTool.SuiCliParser.parse_cmd(
               "sui client import-address AKpjfApmHx8FbjrRRSrUlF6ITigjP8NMS1ip4JdqPp5g"
             )
  end

  test "sui client gas" do
    assert %{cli: :sui_client, cmd: :gas} =
             MoveE2ETestTool.SuiCliParser.parse_cmd("sui client gas")
  end

  test "sui client new-address" do
    assert %{cli: :sui_client, cmd: :new_address, key_schema: "ed25519"} =
             MoveE2ETestTool.SuiCliParser.parse_cmd("sui client new-address ed25519")
  end

  test "sui client call" do
    line =
      "sui client call --function buy_ham --module sandwich --package 0x08204ed92afcfdf9d0f6727a2c7d40db93a059d8 --args args1 args2 --gas gas_obj --gas-budget 30000"

    assert %{
             :args => ["args1", "args2"],
             :cli => :sui_client,
             :cmd => :call,
             :function => "buy_ham",
             :module => "sandwich",
             :package => "0x08204ed92afcfdf9d0f6727a2c7d40db93a059d8",
             :gas => "gas_obj",
             :gas_budget => 30000
           } = MoveE2ETestTool.SuiCliParser.parse_cmd(line)
  end

  def script() do
    "sui client new-address secp256k1
    # 导入一个已有地址
    # 执行 ex 特有的 script

    sui client import-address AKpjfApmHx8FbjrRRSrUlF6ITigjP8NMS1ip4JdqPp5g
    # ex_script: set contract [contract_addr_str]

    # 查看已有地址的 gas 费用
    sui client gas
    # buy_bread
    sui client call --function buy_bread --module sandwich --package 0x08204ed92afcfdf9d0f6727a2c7d40db93a059d8 --args args1 args2 --gas gas_obj --gas-budget 30000
    # check if there is a bread
    # // TODO
    # buy_ham
    sui client call --function buy_ham --module sandwich --package 0x08204ed92afcfdf9d0f6727a2c7d40db93a059d8 --args args1 args2 --gas gas_obj --gas-budget 30000
    # check if there is a ham
    #"
  end
end
