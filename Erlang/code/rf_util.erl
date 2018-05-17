-module(rf_util).

-export([
    time/0,
    date/0,
    localtime/0,
    iso_week_number/0,
    unixtime/0,
    longunixtime/0,
    wee_hours_time/0,

    is_same_day/1,
    is_same_day/2,
    is_same_week/1,
    is_same_week/2,
    is_same_month/1,

    get_call_from/0,
    get_call_from_line/0,
    get_call_from/1,
    get_call_stack/0,
    empty_stacktrace/0,

    timestamp_to_localtime/1,
    localtime_to_timestamp/1,
    cal_date_diff/2,
    sql_time_format/0,
    sql_time_format/1,
    date_diff/2,
    seconds_elapsed_since_this_week/1,

    ceil/1,
    floor/1,
    between/3,
    rand/2,
    rand_f/2,
    rand/0,
    rand_in/1,
    rand_in/2,
    rand_by_weight/2,
    rand_position/2,
    rand_prepare/0,
    shuffle/1,
    shuffle2/2,

    bool_to_int/1,

    md5/1,

    rec_to_pl/2,
    pl_to_rec/3,

    rec_to_maps/2,

    to_binary/1,

    term_to_bitstring/1,
    string_to_term/1,
    bitstring_to_term/1,

    hypot/2,
    angle/2,
    angle_rad/2,
    vector/2,
    unit_vector/2,
    direction/2,
    dir_component/1,
    rotate/2,
    velocity_component/2,
    radian_dir/1,
    radian_dir/2,
    segments_distance/2,
    point_distance/2,

    ets_nth_key/2,
    ets_nth_key_r/2,

    index_of/2,
    set_list_nth/3,
    term_to_string/1,

    get_value/2,
    get_value/3,
    pmap/2,
    upmap/3,

    is_bit_true/2,
    is_any_bit_true/2,
    set_bit_true/2,
    set_bit_false/2,
    set_bit/3,

    is_nth_bit_true/2,
    set_nth_bit_true/2,
    set_nth_bit_false/2,
    set_nth_bit/3,

    count_add/2
    ]).

-define(TIMEZONE_8_SEC, 60 * 60 * 8).
-define(DIFF_SECONDS_0000_1970_UTC_8, 62167248000).


%% 秒
unixtime() ->
    erlang:system_time(seconds).


%% 单位：毫秒
longunixtime() ->
    erlang:system_time(milli_seconds).


%% 获取当天凌晨时间
wee_hours_time() ->
    localtime_to_timestamp({?MODULE:date(), {0,0,0}}).


date() ->
    erlang:date().

time() ->
    erlang:time().

localtime() ->
    erlang:localtime().

iso_week_number() ->
    calendar:iso_week_number().


%% 向上取整 大于N的最小整数
ceil(N) ->
    case trunc(N) of
        M when M == N ->
            M;
        M when N > 0 ->
            M + 1;
        M -> M
    end.


%% 向下取整 小于X的最大整数
floor(X) ->
    case trunc(X) of
        T when X == T ->
            T;
        T when X > 0 ->
            T;
        T -> T - 1
    end.


between(X, Min, _Max) when X < Min ->
    Min;
between(X, _Min, Max) when X > Max ->
    Max;
between(X, _, _) ->
    X.


%%时间戳转本地时间
timestamp_to_localtime(T) ->
    MS = T div 1000000,
    S = T rem 1000000,
    calendar:now_to_local_time({MS,S,0}).

%% 获取指定日期的unix时间戳(只限中国时区)
%% DateTime格式: {{2013,10,9},{17,10,0}}
localtime_to_timestamp(DateTime)->
    calendar:datetime_to_gregorian_seconds(DateTime) - ?DIFF_SECONDS_0000_1970_UTC_8.


is_same_day(Unixtime) ->
    {Date, _} = timestamp_to_localtime(Unixtime),
    ?MODULE:date() =:= Date.

is_same_day(Timestamp1, Timestamp2) ->
    {Date1, _} = timestamp_to_localtime(Timestamp1),
    {Date2, _} = timestamp_to_localtime(Timestamp2),
    Date1 =:= Date2.

%% 判断某个时间戳与现在是否在同一个星期内
is_same_week(Timestamp) ->
    {Date, _} = timestamp_to_localtime(Timestamp),
    ?MODULE:iso_week_number() =:= calendar:iso_week_number(Date).

%% 判断两个时间戳是否在同一个星期内
is_same_week(Timestamp1, Timestamp2) ->
    {Date1, _} = timestamp_to_localtime(Timestamp1),
    {Date2, _} = timestamp_to_localtime(Timestamp2),
    calendar:iso_week_number(Date1) =:= calendar:iso_week_number(Date2).


is_same_month(Timestamp) ->
    {{Y1, M1, _D}, _} = timestamp_to_localtime(Timestamp),
    {Y2, M2, _} = ?MODULE:date(),
    Y1 =:= Y2 andalso M1 =:= M2.


%% 返 yyyy-mm-dd HH:MM:SS 的二进制
sql_time_format() ->
    try fg_time_format_svr:sql_time()
    catch
        _:_ ->
            {{Y, M, D},{HH, MM, SS}} = calendar:local_time(),
            iolist_to_binary(io_lib:format("~4.10.0B-~2.10.0B-~2.10.0B ~2.10.0B:~2.10.0B:~2.10.0B",
                    [Y, M, D, HH, MM, SS]))
    end.

sql_time_format(Unixtime) ->
    {{Y, M, D},{HH, MM, SS}} = timestamp_to_localtime(Unixtime),
    iolist_to_binary(io_lib:format("~4.10.0B-~2.10.0B-~2.10.0B ~2.10.0B:~2.10.0B:~2.10.0B",
                    [Y, M, D, HH, MM, SS])).

%% 两个时间戳的日期差
date_diff(UnixtimeStart, UnixtimeEnd) ->
    Day1 = (UnixtimeStart + ?TIMEZONE_8_SEC) div (60 * 60 * 24),
    Day2 = (UnixtimeEnd + ?TIMEZONE_8_SEC) div (60 * 60 * 24),
    Day2 - Day1.

%计算以Date::{Y,M,D} ,加减DiffDays天变化后日期
cal_date_diff(Date, DiffDays) ->
    T1 = localtime_to_timestamp({Date,{0,0,0}}),
    T2 = T1 + DiffDays * 86400,
    {Date1,_} = timestamp_to_localtime(T2),
    Date1.



-define(ONE_DAY_SECONDS, 86400).

%% 从本周开始到本周指定的时间点已经过去了多少秒？
seconds_elapsed_since_this_week({DayOfTheWeek, Hour, Min, Sec})
        when DayOfTheWeek >= 1 andalso DayOfTheWeek =< 7
            andalso Hour >= 0 andalso Hour =< 23
            andalso Min >= 0 andalso Min =< 59
            andalso Sec >= 0 andalso Sec =< 59 ->
    (DayOfTheWeek-1)*?ONE_DAY_SECONDS + Hour*3600 + Min*60 + Sec.


get_call_from(N) ->
    lists:sublist(rf_util:get_call_stack(), 3, N).

get_call_from() ->
    lists:sublist(rf_util:get_call_stack(), 3, 1).

get_call_from_line() ->
    lists:sublist(rf_util:get_call_stack(), 3, 1).

get_call_stack() ->
    try
        throw(get_call_stack)
    catch
        get_call_stack ->
            Trace1 =
                case erlang:get_stacktrace() of
                    [_|Trace] -> Trace;
                    Trace -> Trace
                end,
            empty_stacktrace(),
            [stack_format(S) || S <- Trace1]
    end.


stack_format({M, F, A, Info}) when is_list(A) ->
    A1 = lists:sublist(fg_util:term_to_string(A), 40),
    case lists:keyfind(line, 1, Info) of
        {_, Line} ->
            {M, F, Line, A1};
        _ ->
            {M, F, A1}
    end;
stack_format({M, F, _A, Info}) ->
    case lists:keyfind(line, 1, Info) of
        {_, Line} ->
            {M, F, Line};
        _ ->
            {M, F}
    end.


empty_stacktrace() ->
    try
        erlang:raise(throw, clear, [])
    catch
        _ ->
            ok
    end.

% record转proplists
rec_to_pl(RecInfo, Record) ->
    rec_to_pl(RecInfo, Record, 2, []).
rec_to_pl([H|T], Record, N, Acc) ->
    Acc1 = [{H, erlang:element(N, Record)}|Acc],
    rec_to_pl(T, Record, N+1, Acc1);
rec_to_pl([], _Record, _N, Acc) ->
    lists:reverse(Acc).

% record转maps
rec_to_maps(RecInfo, Record) ->
    [_|Values] = erlang:tuple_to_list(Record),
    PL = lists:zip(RecInfo, Values),
    maps:from_list(PL).


%% proplists转record
pl_to_rec(List, RecInfo, EmptyRecord) ->
    pl_to_rec(List, RecInfo, EmptyRecord, [], 2).

pl_to_rec(List, [H|T], EmptyRecord, Acc, N) ->
    Elem = get_value(H, List, erlang:element(N, EmptyRecord)),
    pl_to_rec(List, T, EmptyRecord, [Elem|Acc], N+1);
pl_to_rec(_List, [], EmptyRecord, Acc, _N) ->
    Acc1 = lists:reverse(Acc),
    Tag = erlang:element(1, EmptyRecord),
    list_to_tuple([Tag|Acc1]).

to_binary(X) when is_binary(X) ->
    X;
to_binary(X) when is_list(X) ->
    erlang:list_to_binary(X);
to_binary(X) when is_integer(X) ->
    erlang:integer_to_binary(X);
to_binary(X) when is_float(X) ->
    iolist_to_binary(io_lib:format("~w", [X]));
to_binary(X) when is_atom(X) ->
    erlang:atom_to_binary(X, latin1);
to_binary(_) ->
    <<"invalid_to_binary">>.


term_to_bitstring(Term) ->
    erlang:list_to_bitstring(io_lib:format("~999999p", [Term])).

string_to_term(String) ->
    case erl_scan:string(String++".") of
        {ok, Tokens, _} ->
            case erl_parse:parse_term(Tokens) of
                {ok, Term} -> Term;
                _Err -> undefined
            end;
        _Error ->
            undefined
    end.

%% term反序列化，bitstring转换为term，e.g., <<"[{a},1]">>  => [{a},1]
bitstring_to_term(undefined) -> undefined;
bitstring_to_term(<<>>) -> undefined;
bitstring_to_term(BitString) ->
    string_to_term(binary_to_list(BitString)).

%% 依据权重，从元组列表中随机挑选一个元素，返回被抽中的元组，
%%           N是权重所在的位置
rand_by_weight([], _N) ->  %% 传入空列表则抛出异常
    error(badargs);
rand_by_weight(Tuples, N) ->
    Sum = lists:foldl(fun(T, A) -> element(N,T)+A end, 0, Tuples),
    P = rand() * Sum,
    rand_by_weight(Tuples, N, P).

rand_by_weight([H], _, _) ->
    H;
rand_by_weight([H|T], N, P) ->
    case element(N, H) of
        Weight when P =< Weight ->
            H;
        Weight ->
            rand_by_weight(T, N, P-Weight)
    end.

%% 浮点数域的随机
rand_f(Same, Same) ->
    Same;
rand_f(Max, Min) when Max > Min ->
    rand_f(Min, Max);
rand_f(Min, Max) ->
    rand() * (Max - Min) + Min.


rand(Min, Max) when Min < Max ->
    M = Min - 1,
    rand:uniform(Max - M) + M;
rand(Min, Max) when Min == Max ->
    Min;
rand(Max, Min) ->
    rand(Min, Max).

rand() ->
    rand:uniform().


rand_in(List) when is_list(List) ->
    N = rand(1, length(List)),
    lists:nth(N, List);
rand_in(Tuple) when is_tuple(Tuple) ->
    N = rand(1, tuple_size(Tuple)),
    erlang:element(N, Tuple).

rand_in(List, N) when is_list(List) ->
    case length(List) of
        Len when Len =< N ->
            List;
        Len when Len =< 20 ->
            List1 = shuffle(List),
            lists:sublist(List1, N);
        Len when N > Len / 2 ->
            rand_del(Len - N, List, Len);
        Len ->
            rand_in(N, List, Len, [])
    end.

rand_in(N, List, Len, Acc) when N > 0 ->
    P = rand(1, Len),
    Elem = lists:nth(P, List),
    List1 = lists:delete(Elem, List),
    rand_in(N-1, List1, Len-1, [Elem|Acc]);
rand_in(_, _, _, Acc) ->
    Acc.

rand_del(N, List, Len) when N > 0 ->
    P = rand(1, Len),
    Elem = lists:nth(P, List),
    List1 = lists:delete(Elem, List),
    rand_del(N-1, List1, Len-1);
rand_del(_, Acc, _) ->
    Acc.


%% 随机点, 以{PX, PY}为圆心, 以Radius为半径
rand_position({PX, PY}, Radius) ->
    Dir = rf_util:rand() * math:pi(),
    Rad = rf_util:rand() * Radius,
    PX1 = PX + Rad * math:cos(Dir),
    PY1 = PY + Rad * math:sin(Dir),
    {PX1, PY1}.

% lower_bound(Tuples, Pos, Key, L, H) when H > L ->
%     Mid = L + (L - H) div 2,
%     MidRecord = erlang:element(Mid, Tuples),
%     case erlang:element(Pos, MidRecord) < Key of
%         true -> lower_bound(Tuples, Pos, Key, Mid+1, H);
%         false -> lower_bound(Tuples, Pos, Key, L, Mid)
%     end;
% lower_bound(Tuples, Pos, Key, L, H) ->
%     L.

rand_prepare() ->
    Mark = '__rand_prepare__',
    case erlang:get(Mark) of
        undefined ->
            <<A:32, B:32, C:32>> = crypto:strong_rand_bytes(12),
            erlang:put(Mark, {A, B, C}),
            rand:seed(exsplus, {A, B, C});
        _ ->
            ok
    end.

%% 列表乱序(洗牌)
shuffle(L) when is_list(L) ->
    [X || {_,X} <- lists:sort( [{rand:uniform(), N} || N <- L])].

%% 洗到不那么乱的序（更高效率）
%% N 隔几个洗一下
shuffle2(L, N) ->
    do_shuffle2(L, N, N, 0.5, []).

do_shuffle2([], _, _, _, RetList) ->
    [X || {_, X} <- lists:keysort(1, RetList)];
do_shuffle2([H | Rem], Interval, Index, LastRand, RetList) ->
    if
        Index rem Interval =:= 0 ->
            Rand = rand:uniform(),
            do_shuffle2(Rem, Interval, Index + 1, Rand, [{Rand, H} | RetList]);
        true ->
            Rand = LastRand / Interval,
            do_shuffle2(Rem, Interval, Index + 1, LastRand, [{Rand, H} | RetList])
    end.

bool_to_int(B) ->
    case B of
        true -> 1;
        false -> 0
    end.


%% 转换成HEX格式的md5
md5(S) ->
    lists:flatten([io_lib:format("~2.16.0b",[N]) || N <- binary_to_list(erlang:md5(S))]).


hypot(X, Y) ->
    math:sqrt(X*X + Y*Y).


%% 两向量的夹角
angle({X, Y}, _) when X==0 andalso Y == 0 -> 0;
angle(_, {X, Y}) when X==0 andalso Y == 0 -> 0;
angle({AX, AY}, {BX, BY}) ->
    P = AX * BX + AY * BY,
    V = math:sqrt((AX*AX + AY*AY) * (BX*BX + BY*BY)),
    case P/V of
        A when A >= 1 -> % 因为浮点误差有可能会出现 1.000000001
            0;
        A when A =< -1 ->
            180;
        A ->
            math:acos(A) * 180 / math:pi()
    end.


angle_rad({X, Y}, _) when X==0 andalso Y == 0 -> 0;
angle_rad(_, {X, Y}) when X==0 andalso Y == 0 -> 0;
angle_rad({AX, AY}, {BX, BY}) ->
    P = AX * BX + AY * BY,
    V = math:sqrt((AX*AX + AY*AY) * (BX*BX + BY*BY)),
    case P/V of
        A when A >= 1 -> % 因为浮点误差有可能会出现 1.000000001
            0;
        A when A =< -1 ->
            math:pi();
        A ->
            math:acos(A)
    end.


%% 向量AB
vector({Xa, Ya}, {Xb, Yb}) ->
    {Xb-Xa, Yb-Ya}.

%% 单位向量AB
unit_vector(PosA, PosB) ->
    {X, Y} = vector(PosA, PosB),
    direction(X, Y).

%% 求方向向量
direction(X, Y) when X == 0 andalso Y == 0 ->
    {0.0, 0.0};
direction(X, Y) when X == 0 andalso Y < 0 ->
    {0.0, -1.0};
direction(X, _Y) when X == 0 ->
    {0.0, 1.0};
direction(X, Y) when X < 0 andalso Y == 0 ->
    {-1.0, 0.0};
direction(_X, Y) when Y == 0 ->
    {1.0, 0.0};
direction(X, Y) ->
    M = hypot(X, Y),
    {X / M, Y / M}.

%% 从方向角求两个轴上的分量大小
dir_component(R) ->
    {math:cos(R), math:sin(R)}.

%% 从方向角求两个轴上的速度分量大小
velocity_component(R, V) ->
    {math:cos(R) * V, math:sin(R) * V}.

%% 求方向角(弧度, -pi 到 pi )
radian_dir({X, Y}) ->
    radian_dir(X, Y).

radian_dir(X, Y) when X > 0 ->
    math:atan(Y / X);
radian_dir(X, Y) when X < 0 andalso Y > 0->
    math:atan(Y / X) + math:pi();
radian_dir(X, Y) when X < 0 andalso Y < 0->
    math:atan(Y / X) - math:pi();
radian_dir(_X, Y) when Y >= 0 -> % X=0
    math:pi() / 2;
radian_dir(_X, _Y) ->
    - math:pi() / 2.

%% 把向量{X, Y}旋转R弧度
rotate(R, {X, Y}) ->
    {X * math:cos(R) - Y * math:sin(R), X * math:sin(R) + Y * math:cos(R)}.



%% 用于order_set的ets表跳过前N个, 从小到大
ets_nth_key(TabName, Len) ->
    Last = ets:first(TabName),
    ets_nth_key(TabName, Len, Last).

ets_nth_key(_TabName, _Len, '$end_of_table') ->
    '$end_of_table';
ets_nth_key(TabName, Len, Key) when Len > 1 ->
    Key1 = ets:next(TabName, Key),
    ets_nth_key(TabName, Len-1, Key1);
ets_nth_key(_TabName, _Len, Key) ->
    Key.

%% 用于order_set的ets表跳过前N个, 从大到小
ets_nth_key_r(TabName, Len) ->
    Last = ets:last(TabName),
    ets_nth_key_r(TabName, Len, Last).

ets_nth_key_r(_TabName, _Len, '$end_of_table') ->
    '$end_of_table';
ets_nth_key_r(TabName, Len, Key) when Len > 1 ->
    Key1 = ets:prev(TabName, Key),
    ets_nth_key_r(TabName, Len-1, Key1);
ets_nth_key_r(_TabName, _Len, Key) ->
    Key.


%% 线段间距离
segments_distance(S1, S2) ->
    fg_geom:segments_distance(S1, S2).

%% 两点间距离
point_distance(P1, P2) ->
    fg_geom:point_distance(P1, P2).


%% term序列化，term转换为string格式，e.g., [{a},1] => "[{a},1]"
term_to_string(Term) ->
    fg_util:term_to_string(Term).


%% 兼容List和maps的参数提取, 约等于proplist:get_value
get_value(Key, Args) ->
    get_value(Key, Args, undefined).


get_value(Key, Maps, Default) when is_map(Maps) ->
    maps:get(Key, Maps, Default);

get_value(Key, List, Default) when is_list(List) ->
    case lists:keyfind(Key, 1, List) of
        {_, Val} -> Val;
        false -> Default
    end.

%% 并发map, 不限进程数
pmap(F, L) ->
    Parent = self(),
    [receive {Pid, Result} -> Result end
    || Pid <- [spawn(fun() -> Parent ! {self(), (catch F(X))} end) || X <- L]].

%% 并发map, 有限进程数
upmap(Func, List, Limit) when length(List) > Limit ->
    Ref = erlang:make_ref(),
    From = self(),
    Workers = [spawn(fun() -> upmap_worker(Func, From, Ref) end) || _ <- lists:seq(1, Limit)],
    upmap_1(List, Workers, Ref, Limit);

upmap(F, L, _Limit) ->
    pmap(F, L).


upmap_1([ItemH|ItemT], [PidH|PidT], Ref, Limit) ->
    PidH ! {Ref, ItemH},
    upmap_1(ItemT, PidT, Ref, Limit);
upmap_1(Items, [], Ref, Limit) ->
    upmap_2(Items, Ref, Limit, []).


upmap_2([H|T], Ref, Limit, Acc) ->
    receive
        {Ref, WorkerPid, Ret} ->
            WorkerPid ! {Ref, H},
            upmap_2(T, Ref, Limit, [Ret|Acc])
    end;
upmap_2([], Ref, Limit, Acc) ->
    upmap_3(Ref, Limit, Acc).


upmap_3(Ref, N, Acc) when N > 0 ->
    receive
        {Ref, WorkerPid, Ret} ->
            WorkerPid ! stop,
            upmap_3(Ref, N-1, [Ret|Acc])
    end;
upmap_3(_Ref, 0, Acc) ->
    Acc.



upmap_worker(Func, From, Ref) ->
    receive
        {Ref, Item} ->
            From ! {Ref, self(), catch Func(Item)},
            upmap_worker(Func, From, Ref);
        stop ->
            ok
    end.


%% 查找Item在列表List中的位置，如果没有则返回not_found
index_of(Item, List) -> index_of(Item, List, 1).

index_of(_, [], _)  -> not_found;
index_of(Item, [Item | _], Index) -> Index;
index_of(Item, [_ | T], Index) -> index_of(Item, T, Index+1).


%% 替掉列表中的第N项为Item
set_list_nth(N, Item, [H|T]) when N > 1 ->
    [H|set_list_nth(N-1, Item, T)];
set_list_nth(_, Item, [_|T]) ->
    [Item|T].


%% 判断是否所有Needle为1的位都为1
is_bit_true(Needle, Stack)->
    (Stack band Needle) =:= Needle.

%% 判断是否任意Needle为1的位为1
is_any_bit_true(Needle, Stack)->
    (Stack band Needle) > 0.

%% 将Needle中为1的位置为1
set_bit_true(Needle, Stack) ->
    Stack bor Needle.

%% 将Needle中为1的位置为0
set_bit_false(Needle, Stack) ->
    Stack band (bnot Needle).


%% 将Needle中为1的位置为1或0
set_bit(1, Needle, Stack) ->
    Stack bor Needle;
set_bit(true, Needle, Stack) ->
    Stack bor Needle;
set_bit(0, Needle, Stack) ->
    Stack band (bnot Needle);
set_bit(false, Needle, Stack) ->
    Stack band (bnot Needle).


%% 判断第N位置否为1, 位置从右往左计, 最右为第一位
is_nth_bit_true(N, Stack)->
    is_bit_true(1 bsl (N - 1), Stack).

%% 将第N位置为1, 位置从右往左计, 最右为第一位
set_nth_bit_true(N, Stack) ->
    set_bit_true(1 bsl (N - 1), Stack).

%% 将第N位置为0, 位置从右往左计, 最右为第一位
set_nth_bit_false(N, Stack) ->
    set_bit_false(1 bsl (N - 1), Stack).

%% 将第N位置为1或0, 位置从右往左计, 最右为第一位
set_nth_bit(Bool, N, Stack) ->
    set_bit(Bool, 1 bsl (N - 1), Stack).



count_add(Key, Count) ->
    case maps:find(Key, Count) of
        {ok, Val} -> Count#{Key := Val+1};
        _ -> Count#{Key => 1}
    end.

-ifdef(TEST).
-compile([export_all]).
-include_lib("eunit/include/eunit.hrl").



pmap_test() ->
    F = fun(X) -> X * 2 end,
    L = lists:seq(1, 100),
    Correct = lists:sort(lists:map(F, L)),
    ?assertEqual(Correct, lists:sort(pmap(F, L))),
    ?assertEqual(Correct, lists:sort(upmap(F, L, 1))),
    ?assertEqual(Correct, lists:sort(upmap(F, L, 5))),
    ?assertEqual(Correct, lists:sort(upmap(F, L, 10))),
    ?assertEqual(Correct, lists:sort(upmap(F, L, 100))),
    ?assertEqual(Correct, lists:sort(upmap(F, L, 150))).


bit_test() ->
    Needle = 2#00001000,
    true  = is_bit_true(Needle, 2#00001000),
    true  = is_bit_true(Needle, 2#10001000),
    true  = is_bit_true(Needle, 2#10001001),
    false = is_bit_true(Needle, 2#10000001),
    false = is_bit_true(Needle, 2#00000001),
    false = is_bit_true(Needle, 2#00000100),

    true  = is_any_bit_true(Needle, 2#00001000),
    true  = is_any_bit_true(Needle, 2#10001000),
    true  = is_any_bit_true(Needle, 2#10001001),
    false = is_any_bit_true(Needle, 2#10000001),
    false = is_any_bit_true(Needle, 2#00000001),
    false = is_any_bit_true(Needle, 2#00000100),

    2#00001000 = set_bit_true(Needle, 2#00001000),
    2#10001000 = set_bit_true(Needle, 2#10001000),
    2#10001001 = set_bit_true(Needle, 2#10001001),
    2#10001001 = set_bit_true(Needle, 2#10000001),
    2#00001001 = set_bit_true(Needle, 2#00000001),
    2#00001100 = set_bit_true(Needle, 2#00000100),

    2#00000000 = set_bit_false(Needle, 2#00001000),
    2#10000000 = set_bit_false(Needle, 2#10001000),
    2#10000001 = set_bit_false(Needle, 2#10001001),
    2#10000001 = set_bit_false(Needle, 2#10000001),
    2#00000001 = set_bit_false(Needle, 2#00000001),
    2#00000100 = set_bit_false(Needle, 2#00000100),

    N2 = 2#00101000,
    true  = is_bit_true(N2, 2#00101000),
    true  = is_bit_true(N2, 2#00101010),
    true  = is_bit_true(N2, 2#11111111),
    false = is_bit_true(N2, 2#00001000),
    false = is_bit_true(N2, 2#10001000),
    false = is_bit_true(N2, 2#10001001),
    false = is_bit_true(N2, 2#10000001),
    false = is_bit_true(N2, 2#00000001),
    false = is_bit_true(N2, 2#00000100),

    true  = is_any_bit_true(N2, 2#00101000),
    true  = is_any_bit_true(N2, 2#00101010),
    true  = is_any_bit_true(N2, 2#11111111),
    true  = is_any_bit_true(N2, 2#00001000),
    true  = is_any_bit_true(N2, 2#10001000),
    true  = is_any_bit_true(N2, 2#10001001),
    false = is_any_bit_true(N2, 2#10000001),
    false = is_any_bit_true(N2, 2#00000001),
    false = is_any_bit_true(N2, 2#00000100),

    2#11111111 = set_bit_true(N2, 2#11111111),
    2#00101010 = set_bit_true(N2, 2#00101010),
    2#00101000 = set_bit_true(N2, 2#00001000),
    2#10101000 = set_bit_true(N2, 2#10001000),
    2#10101001 = set_bit_true(N2, 2#10001001),
    2#10101001 = set_bit_true(N2, 2#10000001),
    2#00101001 = set_bit_true(N2, 2#00000001),
    2#00101100 = set_bit_true(N2, 2#00000100),

    2#11010111 = set_bit_false(N2, 2#11111111),
    2#00000010 = set_bit_false(N2, 2#00101010),
    2#00000000 = set_bit_false(N2, 2#00101000),
    2#00000000 = set_bit_false(N2, 2#00001000),
    2#10000000 = set_bit_false(N2, 2#10001000),
    2#10000001 = set_bit_false(N2, 2#10001001),
    2#10000001 = set_bit_false(N2, 2#10000001),
    2#00000001 = set_bit_false(N2, 2#00000001),
    2#00000100 = set_bit_false(N2, 2#00000100),

    false = is_nth_bit_true(1, 2#00101010),
    true  = is_nth_bit_true(2, 2#00101010),
    false = is_nth_bit_true(3, 2#00101010),
    true  = is_nth_bit_true(4, 2#00101010),
    false = is_nth_bit_true(100, 2#00101010),

    2#11111111 = set_nth_bit_true(1, 2#11111111),
    2#11111111 = set_nth_bit_true(3, 2#11111111),
    2#11111111 = set_nth_bit_true(5, 2#11111111),
    2#00000001 = set_nth_bit_true(1, 2#00000000),
    2#00000100 = set_nth_bit_true(3, 2#00000000),
    2#00010000 = set_nth_bit_true(5, 2#00000000),

    2#11111110 = set_nth_bit_false(1, 2#11111111),
    2#11111011 = set_nth_bit_false(3, 2#11111111),
    2#11101111 = set_nth_bit_false(5, 2#11111111),
    2#00000000 = set_nth_bit_false(1, 2#00000000),
    2#00000000 = set_nth_bit_false(3, 2#00000000),
    2#00000000 = set_nth_bit_false(5, 2#00000000),
    ok.

set_list_nth_test() ->
    L = [1,2,3,4,5],
    [a, 2, 3, 4, 5] = set_list_nth(1, a, L),
    [1, a, 3, 4, 5] = set_list_nth(2, a, L),
    [1, 2, a, 4, 5] = set_list_nth(3, a, L),
    [1, 2, 3, a, 5] = set_list_nth(4, a, L),
    [1, 2, 3, 4, a] = set_list_nth(5, a, L).


-record(test_rec, {a, b, c}).

rec_to_maps_test() ->
    ?assertEqual(#{a=>1, b=>2, c=>3},
        rec_to_maps(record_info(fields, test_rec), #test_rec{a=1, b=2, c=3})).


a_test() ->
    A = {0.0, 0.0},
    B = {2.0, 2.0},
    C = {2.0, 0.0},
    D = {0.0, 2.0},
    E = {1.0, 1.0},
    F = {1.0, -1.0},
    S1 = {A, D},
    S2 = {B, C},
    S3 = {B, E},
    S4 = {C, F},

    2.0 = rf_util:segments_distance(S1, S2),
    1.0 = rf_util:segments_distance(S1, S3),
    rf_util:segments_distance(S1, S4).

-endif.
