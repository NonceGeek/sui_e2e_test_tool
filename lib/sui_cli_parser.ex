defmodule MoveE2ETestTool.SuiCliParser do
  def parse_cmd(str), do: :erlang.hd(parse_script_to_clis(str))

  def parse_script_to_clis(str) do
    {res, code} = parse_script(str)
    res
  end

  def parse_script_to_code(str) do
    {res, code} = parse_script(str)
    code
  end

  def parse_script(str) do
    {:ok, token, _} = :sui_leex.string(String.to_charlist(str))
    {:ok, {res, code}} = :sui_yecc.parse(token)
    code = :re.replace(code, "\#{", "%{", [:global, {:return, :binary}])
    code = :re.replace(code, "<<\"", "\"", [:global, {:return, :binary}])
    code = :re.replace(code, "\">>", "\"", [:global, {:return, :binary}])

    code =
      "defmodule MoveE2ETestTool.Tmp do\nuse ExUnit.Case\ndef run(agent) do\n" <>
        code <>
        "\nend\nend"

    {res
     |> Enum.map(fn x ->
       Map.to_list(x)
       |> Enum.map(fn {k, v} -> {String.to_atom(k), reset_value(k, v)} end)
       |> :maps.from_list()
     end), code}
  end

  defp reset_value("cli", v), do: String.to_atom(v)
  defp reset_value("cmd", v), do: String.to_atom(v)
  defp reset_value(_, v), do: v
end
