load("//tools:stechec2.bzl", "cc_champion", "e2e_test", "stechec2_replay", "stechec2_run")

cc_library(
    name = "prologin",
    hdrs = ["prologin.hh"],
)

cc_champion(
    name = "libcxx.so",
    srcs = ["prologin.cc"],
)

e2e_test(
    name = "e2e_test",
    game = "tictactoe",
    champions = [
        ":libcxx.so",
        ":libcxx.so",
    ],
    expected_output = """---
player: client-1
score: 0
nb_timeout: 0
---
player: client-2
score: 1
nb_timeout: 0
""",
)

stechec2_run(
    name = "match",
    game = "tictactoe",
    champions = [
        ":libcxx.so",
        ":libcxx.so",
    ],
    replay = True,
)

stechec2_replay(
    name = "replay",
    game = "tictactoe",
    replay = ":match_replay",
)
