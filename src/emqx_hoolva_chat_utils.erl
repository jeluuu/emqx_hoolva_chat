-module(emqx_hoolva_chat_utils).

-export([self_message/3]).

self_message(To, Message11, Message) ->
    io:format("reached self_message\n to : ~p~nmessage1 : ~p~nMessage :~p~n",[To,Message11,Message]),
    From = proplists:get_value(<<"from">>,Message),
    % Message1 = Message ++ [{<<"self">>, true}],
    % FinalMessage = {[{<<"data">>, Message1}]},
    % FinalMessage = proplists:get_value(<<"message">>, Message),
    % EncodedFinalMsg = jsx:encode(element(1,FinalMessage)),

    io:format("~nFrom => ~p~n",[From]),
    Publish = emqx_message:make(From, 2,To ,Message11),
    io:format("~n--- ~p ----~n",[Publish]),
    emqx:publish(Publish).