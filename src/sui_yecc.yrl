Header
"% sui yecc".

Nonterminals root elements element.

Terminals sui comment code.

Rootsymbol root.
root -> elements : '$1'.
elements -> element : init('$1').
elements -> element elements : append('$1', '$2').
element -> sui : value_of('$1').
element -> comment : value_of('$1').
element -> code: value_of('$1').

Erlang code.
init(Cli) ->
{[Cli], cmd(Cli)}.
value_of({_, _, Value} = _Token) ->
    Value.
append(Cli, {List, Acc}) ->
    {[A], Add} = init(Cli),
    {[A | List], [Add, "\n" | Acc]}.
cmd(#{<<"cli">> := <<"sui_client">>} = SuiClient) ->
  io_lib:format("cmd=~p\nres=MoveE2ETestTool.CliParser.cmd(agent, ~p)",[SuiClient, SuiClient]);
cmd(#{<<"cli">> := <<"code">>, <<"line">> := Line}) ->
  io_lib:format("~ts",[Line]);
cmd(#{<<"cli">> := <<"comment">>, <<"line">> := Line}) ->
  Line.


