%% a operator leex
Definitions.
Number = [0-9]+
Float = (\+|-)?{D}\.{D}((E|e)(\+|-)?[0-9]+)?
Space = [\t\s]*
Return = [\r\n]+
NoneLine = {Space}[\r\n]*
Atom = [a-z][0-9a-zA-Z_]*
SuiLine = {Space}sui[\s]+client.+
Comment = {Space}#.+
Code = .*
Debug = {Space}LOG{Space}={Space}DEBUG
Rules.

{Comment} : {token, {comment, TokenLine, parse_comment(TokenChars)}}.
{Debug} : {token, {debug, TokenLine, parse_debug(TokenChars)}}.
{SuiLine} : {token,{sui, TokenLine, parse_sui(TokenChars)}}.
{NoneLine} : skip_token.
%{Return} : {token, {'\n', TokenLine, :nil}}.
{Return} : skip_token.
{Code} : {token, {code, TokenLine, parse_code(TokenChars)}}.

Erlang code.
parse_debug(_) ->
#{<<"cli">> => <<"log">>, <<"cmd">> => <<"debug">>}.
parse_comment(CommentLine) ->
    #{<<"cli">> => <<"comment">>, <<"line">> => unicode:characters_to_binary(CommentLine)}.
parse_code(CodeLine) ->
    #{<<"cli">> => <<"code">>, <<"line">> => erlang:list_to_binary(CodeLine)}.

parse_sui(SuiLine) ->
 {match, List} = re:run(SuiLine, "[0-9a-zA-Z_-]+",[global,{capture,all,binary}]),
 [_Sui, _Client, Method | Rest] = lists:flatten(List),
 parse_sui(Method, Rest).
parse_sui(Method, Args) when
Method == <<"new-address">>;
Method == <<"import-address">> ->
     #{<<"cli">> => <<"sui_client">>, <<"cmd">> => Method, <<"args">> => Args};
parse_sui(Method, Rest)  ->
 do_parse_sui(Rest, #{<<"cli">> => <<"sui_client">>, <<"cmd">> => Method}).
do_parse_sui([], Acc) ->
  Acc;
do_parse_sui([<<"--", H/binary>> | Rest], Acc) ->
 do_parse_sui({H, []}, Rest, Acc).

do_parse_sui({Key, Value}, [], Acc) ->
  append_key_value({Key, Value}, Acc);
do_parse_sui({Key, Value}, [<<"--", _/binary>> | _] = List, Acc) ->
    do_parse_sui(List, append_key_value({Key, Value}, Acc));
do_parse_sui({Key,Value}, [H | Rest], Acc) ->
  do_parse_sui({Key, [H | Value]}, Rest, Acc).

append_key_value({Key, Value}, Acc)   ->
Acc#{Key => lists:reverse(Value)}.
