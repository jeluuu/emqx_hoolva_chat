-module(emqx_hoolva_chat_utils).

-export([self_message/3]).

self_message(To, Message11, Message) ->
    io:format("reached self_message\n to : ~p~nmessage1 : ~p~nMessage :~p~n",[To,Message1,Message]),
    From = proplists:get_value(<<"from">>,Message),
    Message1 = Message ++ [{<<"self">>, true}],
    FinalMessage = {[{<<"data">>, Message1}]},
    EncodedFinalMsg = jsx:encode(element(1,FinalMessage)),
    Publish = emqx_message:make(From, 2,To ,EncodedFinalMsg),
    emqx:publish(Publish).