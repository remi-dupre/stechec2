load("//tools:stechec2.bzl", "cc_champion", "e2e_test")

cc_library(
    name = "prologin",
    hdrs = ["prologin.hh"],
)

cc_champion(
    name = "libcxx.so",
    srcs = ["prologin.cc"],
)

e2e_test(
    name = "cxx_test",
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
