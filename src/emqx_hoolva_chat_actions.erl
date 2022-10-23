-module(emqx_hoolva_chat_actions).

% -behaviour(tivan_server).

-export([
    init/1
  , publish/1
%   , store/1
]).

% start_link() ->
%     tivan_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    TableDefs = #{
        chat => #{columns => #{to_id => #{type => binary
                                        , limit => 30
                                        , null => false}
                                , from_id => #{type => binary}
                                , message => #{type => binary}
                                , time => #{type => integer}
                                }
                        ,audit => true
                  }
        % topic => #{colums => #{}}
    },
    {ok, TableDefs}.

publish(Message) ->
    io:format("Message publish EMQX : ~p",[Message]),       %published by emqx payload
    MsgCheck = element(8,Message),
    case MsgCheck of
        <<"Connection Closed abnormally..!">> ->
            io:format("\nmqtt client closed successfully...!\n");
        _ ->
            io:format("~n ------- checking jsx ----- ~n"),
            % DecodedMessage= element(2,hd(jsx:decode(element(8,Message)))),
            DecodedMessage = jsx:decode(element(8,Message)),
            io:format("sent message publish : ~p ~n",[DecodedMessage]),
            Topic = proplists:get_value(<<"to_id">>,DecodedMessage),
            From = proplists:get_value(<<"from">>,DecodedMessage),
            Message1 = proplists:get_value(<<"message">>,DecodedMessage),
            Date = proplists:get_value(<<"time">>,DecodedMessage),
            emqx_hoolva_chat_utils:self_message(Topic,Message1,DecodedMessage)
        end.

