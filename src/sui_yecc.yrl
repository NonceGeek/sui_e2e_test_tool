Header
"% sui yecc".

Nonterminals root elements element.

Terminals sui comment code debug.

Rootsymbol root.
root -> elements : '$1'.
elements -> element : init('$1').
elements -> element elements : append('$1', '$2').
element -> sui : value_of('$1').
element -> comment : value_of('$1').
element -> code: value_of('$1').
element -> debug: value_of('$1').

Erlang code.
init(Cli) ->
{[Cli], cmd(Cli)}.
value_of({_, _, Value} = _Token) ->
    Value.
append(Cli, {List, Acc}) ->
    {[A], Add} = init(Cli),
    {[A | List], [Add, "\n" | Acc]}.

cmd(#{<<"cli">> := <<"log">>, <<"cmd">> := <<"debug">>}) ->
  io_lib:format(":persistent_term.put(:log,:debug)",[]);
cmd(#{<<"cli">> := <<"sui_client">>} = SuiClient) ->
  io_lib:format("cmd=~p\nres=MoveE2ETestTool.CliParser.cmd(agent, cmd)\nignore_warn(res)\ndebug(cmd, res)",[SuiClient]);
cmd(#{<<"cli">> := <<"code">>, <<"line">> := Line}) ->
  io_lib:format("~ts",[Line]);
cmd(#{<<"cli">> := <<"comment">>, <<"line">> := <<"# ex-script: set-network testnet", _S/binary>>} = Comment) ->
  io_lib:format("cmd=~p\nres=MoveE2ETestTool.CliParser.cmd(agent, cmd)\nignore_warn(res)\ndebug(cmd, res)",[Comment]);
cmd(#{<<"cli">> := <<"comment">>, <<"line">> := <<"# ex-script: sleep 2s", _S/binary>>} = Comment) ->
  io_lib:format("cmd=~p\nres=MoveE2ETestTool.CliParser.cmd(agent, cmd)\nignore_warn(res)\ndebug(cmd, res)",[Comment]);
cmd(#{<<"cli">> := <<"comment">>, <<"line">> := <<"# ex-script: ", S/binary>>} = Comment) ->
  io_lib:format("~ts",[S]);
cmd(#{<<"cli">> := <<"comment">>, <<"line">> := Line} = Comment) ->
  io_lib:format("cmd=~p\nres=MoveE2ETestTool.CliParser.cmd(agent, cmd)\nignore_warn(res)\ndebug(cmd, res)",[Comment]).


