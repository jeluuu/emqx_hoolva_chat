-module(emqx_hoolva_chat_actions).

% -behaviour(tivan_server).

-export([
    init/1
%   , publish/1
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