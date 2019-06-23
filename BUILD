package(
    default_visibility = ["//visibility:public"],
)

VERSION = "git"

cc_library(
    name = "utils",
    srcs = glob(["src/lib/utils/*.cc"]),
    hdrs = glob(["src/lib/utils/*.hh"]),
    copts = [
        "-DMODULE_COLOR=ANSI_COL_PURPLE",
        '-DMODULE_NAME=\\"lib\\"',
    ],
    textual_hdrs = ["src/lib/utils/sandbox.inl"],
    deps = ["//external:gflags"],
)

cc_library(
    name = "net",
    srcs = glob(["src/lib/net/*.cc"]),
    hdrs = glob(["src/lib/net/*.hh"]),
    copts = [
        "-DMODULE_COLOR=ANSI_COL_PURPLE",
        '-DMODULE_NAME=\\"lib\\"',
    ],
    deps = [
        ":utils",
        "@system_libs//:zmq",
        "//external:gflags",
    ],
)

cc_library(
    name = "rules",
    srcs = glob(["src/lib/rules/*.cc"]),
    hdrs = glob(["src/lib/rules/*.hh"]),
    copts = [
        "-DMODULE_COLOR=ANSI_COL_GREEN",
        '-DMODULE_NAME=\\"rules\\"',
    ],
    deps = [
        ":net",
        ":utils",
    ],
)

cc_library(
    name = "client_lib",
    srcs = ["src/client/client.cc"],
    hdrs = ["src/client/client.hh"],
    deps = [
        ":net",
        ":rules",
        "//external:gflags",
    ],
    copts = [
        "-DMODULE_COLOR=ANSI_COL_YELLOW",
        '-DMODULE_NAME=\\"client\\"',
        '-DMODULE_VERSION=\\"%s\\"' % VERSION,
    ],
)

cc_binary(
    name = "client",
    linkopts = ["-ldl"],
    srcs = ["src/client/main.cc"],
    linkstatic = False,
    deps = [":client_lib"],
)

cc_library(
    name = "server_lib",
    deps = [":net", ":rules", "//external:gflags"],
    srcs = ["src/server/server.cc"],
    hdrs = ["src/server/server.hh"],
    copts = [
        "-DMODULE_COLOR=ANSI_COL_RED",
        '-DMODULE_NAME=\\"server\\"',
        '-DMODULE_VERSION=\\"%s\\"' % VERSION,
    ],
)

cc_binary(
    name = "server",
    linkopts = ["-ldl"],
    srcs = ["src/server/main.cc"],
    deps = [":server_lib"],
    linkstatic = False,
)
