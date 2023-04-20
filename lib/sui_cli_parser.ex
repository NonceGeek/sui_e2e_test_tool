defmodule MoveE2ETestTool.SuiCliParser do
  def parse_cmd(str), do: :erlang.hd(parse_script_to_clis(str))

  def parse_script_to_clis(str) do
    {res, code} = parse_script(str)
    res
  end

  def parse_script_to_code(str, module \\ "Tmp") do
    {res, code} = parse_script(str, module)
    code
  end

  def parse_script(str, module \\ "Tmp") do
    {:ok, token, _} = :sui_leex.string(String.to_charlist(str))
    {:ok, {res, code}} = :sui_yecc.parse(token)
    code = :re.replace(code, "\#{", "%{", [:global, {:return, :binary}])
    code = :re.replace(code, "<<\"", "\"", [:global, {:return, :binary}])
    code = :re.replace(code, "\">>", "\"", [:global, {:return, :binary}])
    code = :re.replace(code, "%{inspect", "\#{inspect", [:global, {:return, :binary}])

    code =
      "defmodule MoveE2ETestTool." <> module <> " do\nuse ExUnit.Case\ndef run(agent) do\n:persistent_term.put(:log,:nil)\n" <>
        code <>
        "\nend\ndef ignore_warn(_res), do: :ok \n" <> debug() <> "\nend"

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
  defp debug() do
    "
    def debug(cmd, res) do
    case :persistent_term.get(:log) do
        :debug ->
              IO.puts(IO.ANSI.format([:blue, \"===> \#{inspect(cmd)}\"]))
              IO.puts(IO.ANSI.format([:green, \".... \#{inspect(res, pretty: true)}\n\n\"]))
         :ok
        :nil -> :ignore
    end
    end
    "
    end
end
