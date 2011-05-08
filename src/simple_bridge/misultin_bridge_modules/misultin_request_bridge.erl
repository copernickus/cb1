-module (misultin_request_bridge).
-behaviour (simple_bridge_request).
-include_lib ("simple_bridge.hrl").
-export ([
    init/1,
    request_method/1, path/1, uri/1,
    peer_ip/1, peer_port/1,
    headers/1, cookies/1,
    query_params/1, post_params/1, request_body/1
]).


%% @todo could not figure out how to get the socket from misultin 
%% so could not implement socket/1, recv_from_socket/3 that are 
%% present in other request modules 

init(Req) -> 
    Req.

request_method({Req, _DocRoot}) -> 
    Req:get(method).

path({Req, _DocRoot}) -> 
    {abs_path,Path} = Req:get(uri),
    Path.

uri({Req, _DocRoot}) ->
    Req:get(uri).

peer_ip({Req, _DocRoot}) -> 
    Req:get(peer_addr).

peer_port({Req, _DocRoot}) -> 
    Req:get(peer_port).

headers({Req, _DocRoot}) ->
    Headers = Req:get(headers),
    F = fun(Header) -> proplists:get_value(Header, Headers) end,
    Headers1 = [
        {connection, F('Connection')},
        {accept, F('Accept')},
        {host, F('Host')},
        {if_modified_since, F('If-Modified-Since')},
        {if_match, F('If-Match')},
        {if_none_match, F('If-Range')},
        {if_unmodified_since, F('If-Unmodified-Since')},
        {range, F('Range')},
        {referer, F('Referer')},
        {user_agent, F('User-Agent')},
        {accept_ranges, F('Accept-Ranges')},
        {cookie, F('Cookie')},
        {keep_alive, F('Keep-Alive')},
        {location, F('Location')},
        {content_length, F('Content-Length')},
        {content_type, F('Content-Type')},
        {content_encoding, F('Content-Encoding')},
        {authorization, F('Authorization')},
        {transfer_encoding, F('Transfer-Encoding')}
    ],
    [{K, V} || {K, V} <- Headers1, V /= undefined].

cookies({Req, DocRoot}) ->
    Headers = headers({Req, DocRoot}),
    CookieData = proplists:get_value(cookie, Headers, ""),
    F = fun(Cookie) ->
        case string:tokens(Cookie, "=") of
            [] -> [];
            L -> 
                X = string:strip(hd(L)),
                Y = string:join(tl(L), "="),
                {X, Y}
        end
    end,
    [F(X) || X <- string:tokens(CookieData, ";")].

query_params({Req, _DocRoot}) ->
    Req:parse_qs().	

post_params({Req, _DocRoot}) ->
    Req:parse_post().

request_body({Req, _DocRoot}) ->
    Req:get(body).
