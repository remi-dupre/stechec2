package(
    default_visibility = ["//visibility:public"],
)

GAMES = glob(["*"], exclude = ["wscript", "BUILD"], exclude_directories = 0)

[cc_library(
    name = game,
    srcs = glob([game + "/src/*.cc"]),
    hdrs = glob([game + "/src/*.hh"]),
    copts = [
        "-Wno-return-type-c-linkage",
        "-DMODULE_COLOR=ANSI_COL_BROWN",
        '-DMODULE_NAME=\\"rules\\"',
    ],
    deps = ["//:rules"],
) for game in GAMES]

[cc_binary(
    name = game + ".so",
    deps = [":" + game],
    linkshared = True,
    linkstatic = False,
) for game in GAMES]

[[cc_test(
    name = test[:-len(".cc")],
    srcs = [test] + glob([game + "/src/tests/*.hh"]),
    deps = [
        ":" + game,
        "//:rules",
        "@googletest//:gtest_main",
    ],
    copts = [
        "-DMODULE_COLOR=ANSI_COL_PURPLE",
        '-DMODULE_NAME=\\"test\\"',
    ],
    linkopts = ["-ldl"],
) for test in glob([game + "/src/tests/*.cc"])] for game in GAMES]
