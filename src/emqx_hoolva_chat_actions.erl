-module(emqx_hoolva_chat_actions).

-behaviour(tivan_server).

-export([
    init/1
  , publish/1
%   , store/1
  ,put_chat/1
  ,get_chat/0
  ,get_chat/1
  ,put_transaction/1
  ,get_transaction/0
  ,get_transaction/1
]).

-export([start_link/0]).

start_link() ->
    tivan_server:start_link({local, ?MODULE}, ?MODULE, [], []).

% --- chats tivan ------
put_chat(Chat) when is_map(Chat) ->
    tivan_server:put(?MODULE, chats, Chat).

get_chat() ->
  get_chat(#{}).

get_chat(Options) when is_map(Options) ->
  tivan_server:get(?MODULE, chats, Options).

%--- transaction tivan------
put_transaction(Chat) when is_map(Chat) ->
    tivan_server:put(?MODULE, transaction, Chat).

get_transaction() ->
  get_chat(#{}).

get_transaction(Options) when is_map(Options) ->
  tivan_server:get(?MODULE, transaction, Options).

init([]) ->
    TableDefs = #{
        chats => #{columns => #{to_id => #{type => binary
                                        , limit => 30
                                        , null => false}
                                , transactions => #{type => [transaction]}
                                % , from_id => #{type => [binary]}
                                % , message => #{type => [binary]}
                                % , time => #{type => [binary]}
                                }
                        ,audit => true
                  },
                
        transaction => #{columns => #{transaction_id => #{type => binary
                                                       , unique => true 
                                                       , key => true}
                                    , from_id => #{type => binary}
                                    , message => #{type => binary}
                                    , time => #{type => binary}                   
                                    }
                            ,audit => true 
                  }
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
            % DecodedMessage= [element(2,hd(jsx:decode(element(8,Message))))],
            DecodedMessage = jsx:decode(element(8,Message)),
            io:format("sent message publish : ~p ~n",[DecodedMessage]),
            Topic = proplists:get_value(<<"to_id">>,DecodedMessage),
            io:format("to_id => ~p~n", [Topic]),
            From = proplists:get_value(<<"from">>,DecodedMessage),
            Message1 = proplists:get_value(<<"message">>,DecodedMessage),
            Date = proplists:get_value(<<"time">>,DecodedMessage),
            Transaction_id = proplists:get_value(<<"transaction_id">>,DecodedMessage),
            emqx_hoolva_chat_utils:self_message(Topic,Message1,DecodedMessage),

            TransOutput = #{transaction_id => Transaction_id
                        , from_id => From
                        , message => Message1
                        , time => Date
                    },
            put_transaction(TransOutput),
            Transaction = get_transaction(TransOutput),

            ChatOutput = #{to_id => Topic
                        , transactions => [Transaction]},
            case get_chat(#{to_id => Topic}) of
                [] ->
                    io:format("~nno to_id found ..so creating new ~n"),
                % change
                    
                    put_chat(ChatOutput),
                    P = get_chat(#{to_id => Topic}),
                    io:format("~n tivan ---- get_chat ~p ~n",[P]);
                [R] ->

                    io:format("~n already exist ~n"),
                    % From0 = maps:get(from_id,R) ++ [From],
                    % Message0 = maps:get(message,R) ++ [Message1],
                    % Date0 = maps:get(time,R) ++ [Date],
                    Trans = maps:get(transactions,R) ++ [Transaction_id],
                    % T = get_transaction(Trans),
                    % io:format("~n added ~p --- ~p --- ~p ~n",[From0,Message0,Date0]),

                    % ChatOutput1 = R#{
                    %      from_id => From0
                    %     , message => Message0
                    %     , time => Date0
                    % },
                    ChatOutput1 = R#{
                        transactions => Trans
                    },
                    put_chat(ChatOutput1),
                    P = get_chat(#{to_id => Topic}),
                    io:format("~n tivan ---- get_chat ~p ~n",[P])

                end

            % emqx_hoolva_chat_utils:self_message(Topic,Message1,DecodedMessage)
        end.

