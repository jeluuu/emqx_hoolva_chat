-module(emqx_hoolva_chat_actions).

-behaviour(tivan_server).

-export([
    init/1
  , publish/1
%   , store/1
  ,put_chat/1
  ,get_chat/0
  ,get_chat/1
]).

-export([start_link/0]).

start_link() ->
    tivan_server:start_link({local, ?MODULE}, ?MODULE, [], []).

put_chat(Chat) when is_map(Chat) ->
    tivan_server:put(?MODULE, chats, Chat).

get_chat() ->
  get_chat(#{}).

get_chat(Options) when is_map(Options) ->
  tivan_server:get(?MODULE, chats, Options).

init([]) ->
    TableDefs = #{
        chats => #{columns => #{to_id => #{type => binary
                                        , limit => 30
                                        , null => false}
                                , from_id => #{type => binary}
                                , message => #{type => binary}
                                , time => #{type => binary}
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
            % DecodedMessage= [element(2,hd(jsx:decode(element(8,Message))))],
            DecodedMessage = jsx:decode(element(8,Message)),
            io:format("sent message publish : ~p ~n",[DecodedMessage]),
            Topic = proplists:get_value(<<"to_id">>,DecodedMessage),
            io:format("to_id => ~p~n", [Topic]),
            From = proplists:get_value(<<"from">>,DecodedMessage),
            Message1 = proplists:get_value(<<"message">>,DecodedMessage),
            Date = proplists:get_value(<<"time">>,DecodedMessage),
            emqx_hoolva_chat_utils:self_message(Topic,Message1,DecodedMessage),

            ChatOutput = #{to_id => Topic
                        , from_id => From
                        , message => Message1
                        , time => Date
                    },
            put_chat(ChatOutput)
            %case get_chat(#{to_id => Topic}) of
            %    [] ->
            %        io:format("~nno to_id found ..so creating new ~n"),
            %        put_chat(ChatOutput),
                    % P = get_chat(#{to_id => Topic}),
                %     io:format("~n tivan ---- get_chat ~p ~n",[P]);
                % % [#{to_id := Topic, from_id := From0, message := Message0, time := Time0}] ->
                % [R] ->

                %     io:format("~n already exist ~n"),
                %     From0 = maps:get(from_id,R) ++ [From],
                %     Message0 = maps:get(message,R) ++ [Message1],
                %     Date0 = maps:get(time,R) ++ [Date],
                %     io:format("~n added ~p --- ~p --- ~p ~n",[From0,Message0,Date0]),

                %     ChatOutput1 = R#{
                %          from_id => From0
                %         , message => Message0
                %         , time => Date0
                %     },
                %     put_chat(ChatOutput1),
                %     P = get_chat(#{to_id => Topic}),
                %     io:format("~n tivan ---- get_chat ~p ~n",[P])

                % end

            % emqx_hoolva_chat_utils:self_message(Topic,Message1,DecodedMessage)
        end.

