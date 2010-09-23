%%%-------------------------------------------------------------------
%%% @author Juan Jose Comellas <juanjo@comellas.org>
%%% @copyright (C) 2009 Juan Jose Comellas
%%% @doc Parses command line options with a format similar to that of GNU getopt.
%%%
%%% This source file is subject to the New BSD License. You should have received
%%% a copy of the New BSD license with this software. If not, it can be
%%% retrieved from: http://www.opensource.org/licenses/bsd-license.php
%%%-------------------------------------------------------------------

-module(getopt_test).
-author('juanjo@comellas.org').

-include_lib("eunit/include/eunit.hrl").

-import(getopt, [parse/2, usage/2]).

-define(NAME(Opt), element(1, Opt)).
-define(SHORT(Opt), element(2, Opt)).
-define(LONG(Opt), element(3, Opt)).
-define(ARG_SPEC(Opt), element(4, Opt)).
-define(HELP(Opt), element(5, Opt)).


%%%-------------------------------------------------------------------
%%% UNIT TESTS
%%%-------------------------------------------------------------------

%%% Test for the getopt/1 function
parse_1_test_() ->
    Short           = {short,              $a,        undefined,            undefined,                      "Option with only short form and no argument"},
    Short2          = {short2,             $b,        undefined,            undefined,                      "Second option with only short form and no argument"},
    Short3          = {short3,             $c,        undefined,            undefined,                      "Third option with only short form and no argument"},
    ShortArg        = {short_arg,          $d,        undefined,            string,                         "Option with only short form and argument"},
    ShortDefArg     = {short_def_arg,      $e,        undefined,            {string, "default-short"},      "Option with only short form and default argument"},
    ShortBool       = {short_bool,         $f,        undefined,            boolean,                        "Option with only short form and boolean argument"},
    ShortInt        = {short_int,          $g,        undefined,            integer,                        "Option with only short form and integer argument"},
    ShortFloat      = {short_float,        $h,        undefined,            float,                          "Option with only short form and float argument"},
    Long            = {long,               undefined, "long",               undefined,                      "Option with only long form and no argument"},
    LongArg         = {long_arg,           undefined, "long-arg",           string,                         "Option with only long form and argument"},
    LongDefArg      = {long_def_arg,       undefined, "long-def-arg",       {string, "default-long"},       "Option with only long form and default argument"},
    LongBool        = {long_bool,          undefined, "long-bool",          boolean,                        "Option with only long form and boolean argument"},
    LongInt         = {long_int,           undefined, "long-int",           integer,                        "Option with only long form and integer argument"},
    LongFloat       = {long_float,         undefined, "long-float",         float,                          "Option with only long form and float argument"},
    ShortLong       = {short_long,         $i,        "short-long",         undefined,                      "Option with short form, long form and no argument"},
    ShortLongArg    = {short_long_arg,     $j,        "short-long-arg",     string,                         "Option with short form, long form and argument"},
    ShortLongDefArg = {short_long_def_arg, $k,        "short-long-def-arg", {string, "default-short-long"}, "Option with short form, long form and default argument"},
    ShortLongBool   = {short_long_bool,    $l,        "short-long-bool",    boolean,                        "Option with short form, long form and boolean argument"},
    ShortLongInt    = {short_long_int,     $m,        "short-long-int",     integer,                        "Option with short form, long form and integer argument"},
    ShortLongFloat  = {short_long_float,   $n,        "short-long-float",   float,                          "Option with short form, long form and float argument"},
    NonOptArg       = {non_opt_arg,        undefined, undefined,            undefined,                      "Non-option argument"},
    NonOptBool      = {non_opt_bool,       undefined, undefined,            boolean,                        "Non-option boolean argument"},
    NonOptInt       = {non_opt_int,        undefined, undefined,            integer,                        "Non-option integer argument"},
    NonOptFloat     = {non_opt_float,      undefined, undefined,            float,                          "Non-option float argument"},
    CombinedOptSpecs =
        [
         Short,
         ShortArg,
         ShortBool,
         ShortInt,
         Short2,
         Short3,
         Long,
         LongArg,
         LongBool,
         LongInt,
         ShortLong,
         ShortLongArg,
         ShortLongBool,
         ShortLongInt,
         NonOptArg,
         NonOptInt,
         ShortDefArg,
         LongDefArg,
         ShortLongDefArg
        ],
    CombinedArgs =
        [
         [$-, ?SHORT(Short)],
         [$-, ?SHORT(ShortArg)], "value1",
         [$-, ?SHORT(ShortBool)],
         [$-, ?SHORT(ShortInt)], "100",
         [$-, ?SHORT(Short2), ?SHORT(Short3)],
         "--long",
         "--long-arg", "value2",
         "--long-bool", "true",
         "--long-int", "101",
         [$-, ?SHORT(ShortLong)],
         "--short-long-arg", "value3",
         "--short-long-bool", "false",
         "--short-long-int", "103",
         "value4",
         "104",
         "dummy1",
         "dummy2"
        ],
    CombinedOpts =
        [
         ?NAME(Short),
         {?NAME(ShortArg), "value1"},
         {?NAME(ShortBool), true},
         {?NAME(ShortInt), 100},
         ?NAME(Short2),
         ?NAME(Short3),
         ?NAME(Long),
         {?NAME(LongArg), "value2"},
         {?NAME(LongBool), true},
         {?NAME(LongInt), 101},
         ?NAME(ShortLong),
         {?NAME(ShortLongArg), "value3"},
         {?NAME(ShortLongBool), false},
         {?NAME(ShortLongInt), 103},
         {?NAME(NonOptArg), "value4"},
         {?NAME(NonOptInt), 104},
         {?NAME(ShortDefArg), "default-short"},
         {?NAME(LongDefArg), "default-long"},
         {?NAME(ShortLongDefArg), "default-short-long"}
        ],
    CombinedRest = ["dummy1", "dummy2"],
         
    [
     {"No options and no arguments",
      ?_assertMatch({ok, {[], []}}, parse([], []))},
     {"Options and no arguments",
      ?_assertMatch({ok, {[], []}}, parse([Short], []))},
     {"No options and single argument",
      ?_assertMatch({ok, {[], ["arg1"]}}, parse([], ["arg1"]))},
     {"No options and arguments",
      ?_assertMatch({ok, {[], ["arg1", "arg2"]}}, parse([], ["arg1", "arg2"]))},
     {"Unused options and arguments",
      ?_assertMatch({ok, {[], ["arg1", "arg2"]}}, parse([Short], ["arg1", "arg2"]))},
     %% Option terminator
     {"Option terminator before arguments",
      ?_assertEqual({ok, {[], [[$-, ?SHORT(Short)], "arg1", "arg2"]}}, parse([Short], ["--", [$-, ?SHORT(Short)], "arg1", "arg2"]))},
     {"Option terminator between arguments",
      ?_assertEqual({ok, {[], ["arg1", [$-, ?SHORT(Short)], "arg2"]}}, parse([Short], ["arg1", "--", [$-, ?SHORT(Short)], "arg2"]))},
     {"Option terminator after options",
      ?_assertMatch({ok, {[short], ["arg1", "arg2"]}}, parse([Short], [[$-, ?SHORT(Short)], "--", "arg1", "arg2"]))},
     {"Option terminator at the end",
      ?_assertMatch({ok, {[short], ["arg1", "arg2"]}}, parse([Short], [[$-, ?SHORT(Short)], "arg1", "arg2", "--"]))},
     %% Options with only the short form
     {?HELP(Short),           ?_assertMatch({ok, {[short], []}}, parse([Short], [[$-, ?SHORT(Short)]]))},
     {?HELP(ShortArg),        ?_assertMatch({ok, {[{short_arg, "value"}], []}}, parse([ShortArg], [[$-, ?SHORT(ShortArg)], "value"]))},
     {?HELP(ShortDefArg),     ?_assertMatch({ok, {[{short_def_arg, "default-short"}], []}}, parse([ShortDefArg], []))},
     {?HELP(ShortBool),       ?_assertMatch({ok, {[{short_bool, true}], []}}, parse([ShortBool], [[$-, ?SHORT(ShortBool)]]))},
     {?HELP(ShortBool),       ?_assertMatch({ok, {[{short_bool, true}], []}}, parse([ShortBool], [[$-, ?SHORT(ShortBool), $t]]))},
     {?HELP(ShortBool),       ?_assertMatch({ok, {[{short_bool, true}], []}}, parse([ShortBool], [[$-, ?SHORT(ShortBool), $1]]))},
     {?HELP(ShortBool),       ?_assertMatch({ok, {[{short_bool, true}], []}}, parse([ShortBool], [[$-, ?SHORT(ShortBool)], "true"]))},
     {?HELP(ShortBool),       ?_assertMatch({ok, {[{short_bool, false}], []}}, parse([ShortBool], [[$-, ?SHORT(ShortBool), $f]]))},
     {?HELP(ShortBool),       ?_assertMatch({ok, {[{short_bool, false}], []}}, parse([ShortBool], [[$-, ?SHORT(ShortBool), $0]]))},
     {?HELP(ShortBool),       ?_assertMatch({ok, {[{short_bool, false}], []}}, parse([ShortBool], [[$-, ?SHORT(ShortBool)], "false"]))},
     {?HELP(ShortInt),        ?_assertMatch({ok, {[{short_int, 100}], []}}, parse([ShortInt], [[$-, ?SHORT(ShortInt), $1, $0, $0]]))},
     {?HELP(ShortInt),        ?_assertMatch({ok, {[{short_int, 100}], []}}, parse([ShortInt], [[$-, ?SHORT(ShortInt)], "100"]))},
     {?HELP(ShortFloat),      ?_assertMatch({ok, {[{short_float, 1.0}], []}}, parse([ShortFloat], [[$-, ?SHORT(ShortFloat), $1, $., $0]]))},
     {?HELP(ShortFloat),      ?_assertMatch({ok, {[{short_float, 1.0}], []}}, parse([ShortFloat], [[$-, ?SHORT(ShortFloat)], "1.0"]))},
     {"Unsorted multiple short form options and arguments in a single string",
      ?_assertMatch({ok, {[short, short2, short3], ["arg1", "arg2"]}}, parse([Short, Short2, Short3], "arg1 -abc arg2"))},
     {"Short form option and arguments",
      ?_assertMatch({ok, {[short], ["arg1", "arg2"]}}, parse([Short], [[$-, ?SHORT(Short)], "arg1", "arg2"]))},
     {"Short form option and arguments (unsorted)",
      ?_assertMatch({ok, {[short], ["arg1", "arg2"]}}, parse([Short], ["arg1", [$-, ?SHORT(Short)], "arg2"]))},
     %% Options with only the long form
     {?HELP(Long),            ?_assertMatch({ok, {[long], []}}, parse([Long], ["--long"]))},
     {?HELP(LongArg),         ?_assertMatch({ok, {[{long_arg, "value"}], []}}, parse([LongArg], ["--long-arg", "value"]))},
     {?HELP(LongArg),         ?_assertMatch({ok, {[{long_arg, "value"}], []}}, parse([LongArg], ["--long-arg=value"]))},
     {?HELP(LongArg),         ?_assertMatch({ok, {[{long_arg, "value=1"}], []}}, parse([LongArg], ["--long-arg=value=1"]))},
     {?HELP(LongDefArg),      ?_assertMatch({ok, {[{long_def_arg, "default-long"}], []}}, parse([LongDefArg], []))},
     {?HELP(LongBool),        ?_assertMatch({ok, {[{long_bool, true}], []}}, parse([LongBool], ["--long-bool"]))},
     {?HELP(LongBool),        ?_assertMatch({ok, {[{long_bool, true}], []}}, parse([LongBool], ["--long-bool=t"]))},
     {?HELP(LongBool),        ?_assertMatch({ok, {[{long_bool, true}], []}}, parse([LongBool], ["--long-bool=1"]))},
     {?HELP(LongBool),        ?_assertMatch({ok, {[{long_bool, true}], []}}, parse([LongBool], ["--long-bool", "true"]))},
     {?HELP(LongBool),        ?_assertMatch({ok, {[{long_bool, false}], []}}, parse([LongBool], ["--long-bool=f"]))},
     {?HELP(LongBool),        ?_assertMatch({ok, {[{long_bool, false}], []}}, parse([LongBool], ["--long-bool=0"]))},
     {?HELP(LongBool),        ?_assertMatch({ok, {[{long_bool, false}], []}}, parse([LongBool], ["--long-bool", "false"]))},
     {?HELP(LongInt),         ?_assertMatch({ok, {[{long_int, 100}], []}}, parse([LongInt], ["--long-int", "100"]))},
     {?HELP(LongInt),         ?_assertMatch({ok, {[{long_int, 100}], []}}, parse([LongInt], ["--long-int=100"]))},
     {?HELP(LongFloat),       ?_assertMatch({ok, {[{long_float, 1.0}], []}}, parse([LongFloat], ["--long-float", "1.0"]))},
     {?HELP(LongFloat),       ?_assertMatch({ok, {[{long_float, 1.0}], []}}, parse([LongFloat], ["--long-float=1.0"]))},
     {"Long form option and arguments",
      ?_assertMatch({ok, {[long], ["arg1", "arg2"]}}, parse([Long], ["--long", "arg1", "arg2"]))},
     {"Long form option and arguments (unsorted)",
      ?_assertMatch({ok, {[long], ["arg1", "arg2"]}}, parse([Long], ["arg1", "--long", "arg2"]))},
     %% Options with both the short and long form
     {?HELP(ShortLong),       ?_assertMatch({ok, {[short_long], []}}, parse([ShortLong], [[$-, ?SHORT(ShortLong)]]))},
     {?HELP(ShortLong),       ?_assertMatch({ok, {[short_long], []}}, parse([ShortLong], ["--short-long"]))},
     {?HELP(ShortLongArg),    ?_assertMatch({ok, {[{short_long_arg, "value"}], []}}, parse([ShortLongArg], [[$-, ?SHORT(ShortLongArg)], "value"]))},
     {?HELP(ShortLongArg),    ?_assertMatch({ok, {[{short_long_arg, "value"}], []}}, parse([ShortLongArg], ["--short-long-arg", "value"]))},
     {?HELP(ShortLongArg),    ?_assertMatch({ok, {[{short_long_arg, "value"}], []}}, parse([ShortLongArg], ["--short-long-arg=value"]))},
     {?HELP(ShortLongDefArg), ?_assertMatch({ok, {[{short_long_def_arg, "default-short-long"}], []}}, parse([ShortLongDefArg], []))},
     {?HELP(ShortLongBool),   ?_assertMatch({ok, {[{short_long_bool, true}], []}}, parse([ShortLongBool], [[$-, ?SHORT(ShortLongBool)]]))},
     {?HELP(ShortLongBool),   ?_assertMatch({ok, {[{short_long_bool, true}], []}}, parse([ShortLongBool], [[$-, ?SHORT(ShortLongBool), $1]]))},
     {?HELP(ShortLongBool),   ?_assertMatch({ok, {[{short_long_bool, true}], []}}, parse([ShortLongBool], [[$-, ?SHORT(ShortLongBool)], "yes"]))},
     {?HELP(ShortLongBool),   ?_assertMatch({ok, {[{short_long_bool, true}], []}}, parse([ShortLongBool], ["--short-long-bool", "on"]))},
     {?HELP(ShortLongBool),   ?_assertMatch({ok, {[{short_long_bool, true}], []}}, parse([ShortLongBool], ["--short-long-bool=enabled"]))},
     {?HELP(ShortLongBool),   ?_assertMatch({ok, {[{short_long_bool, false}], []}}, parse([ShortLongBool], [[$-, ?SHORT(ShortLongBool), $0]]))},
     {?HELP(ShortLongBool),   ?_assertMatch({ok, {[{short_long_bool, false}], []}}, parse([ShortLongBool], [[$-, ?SHORT(ShortLongBool)], "no"]))},
     {?HELP(ShortLongBool),   ?_assertMatch({ok, {[{short_long_bool, false}], []}}, parse([ShortLongBool], ["--short-long-bool", "off"]))},
     {?HELP(ShortLongBool),   ?_assertMatch({ok, {[{short_long_bool, false}], []}}, parse([ShortLongBool], ["--short-long-bool=disabled"]))},
     {?HELP(ShortLongInt),    ?_assertMatch({ok, {[{short_long_int, 1234}], []}}, parse([ShortLongInt], [[$-, ?SHORT(ShortLongInt)], "1234"]))},
     {?HELP(ShortLongInt),    ?_assertMatch({ok, {[{short_long_int, 1234}], []}}, parse([ShortLongInt], ["--short-long-int", "1234"]))},
     {?HELP(ShortLongInt),    ?_assertMatch({ok, {[{short_long_int, 1234}], []}}, parse([ShortLongInt], ["--short-long-int=1234"]))},
     {?HELP(ShortLongFloat),  ?_assertMatch({ok, {[{short_long_float, 1.0}], []}}, parse([ShortLongFloat], [[$-, ?SHORT(ShortLongFloat)], "1.0"]))},
     {?HELP(ShortLongFloat),  ?_assertMatch({ok, {[{short_long_float, 1.0}], []}}, parse([ShortLongFloat], ["--short-long-float", "1.0"]))},
     {?HELP(ShortLongFloat),  ?_assertMatch({ok, {[{short_long_float, 1.0}], []}}, parse([ShortLongFloat], ["--short-long-float=1.0"]))},
     %% Non-option arguments
     {?HELP(NonOptArg),       ?_assertMatch({ok, {[{non_opt_arg, "value"}], []}}, parse([NonOptArg], ["value"]))},
     {?HELP(NonOptBool),      ?_assertMatch({ok, {[{non_opt_bool, false}], []}}, parse([NonOptBool], ["n"]))},
     {?HELP(NonOptInt),       ?_assertMatch({ok, {[{non_opt_int, 1234}], []}}, parse([NonOptInt], ["1234"]))},
     {?HELP(NonOptFloat),     ?_assertMatch({ok, {[{non_opt_float, 1.0}], []}}, parse([NonOptFloat], ["1.0"]))},
     {"Declared and undeclared non-option arguments",
     ?_assertMatch({ok, {[{non_opt_arg, "arg1"}], ["arg2", "arg3"]}}, parse([NonOptArg], ["arg1", "arg2", "arg3"]))},
     %% Combined
     {"Combined short, long and non-option arguments",
      ?_assertEqual({ok, {CombinedOpts, CombinedRest}}, parse(CombinedOptSpecs, CombinedArgs))},
     {"Option with only short form and invalid integer argument",
      ?_assertEqual({error, {invalid_option_arg, {?NAME(ShortInt), "value"}}}, parse([ShortInt], [[$-, ?SHORT(ShortInt)], "value"]))}
    ].