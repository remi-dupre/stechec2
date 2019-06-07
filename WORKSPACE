load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")

git_repository(
    name = "com_github_gflags_gflags",
    remote = "https://github.com/gflags/gflags.git",
    tag = "v2.2.2",
)

bind(
    actual = "@com_github_gflags_gflags//:gflags",
    name = "gflags",
)

new_git_repository(
    name = "googletest",
    build_file = "gmock.BUILD",
    remote = "https://github.com/google/googletest",
    tag = "release-1.8.0",
)

new_local_repository(
    name = "system_libs",
    path = "/usr/lib/",
    build_file_content = """
cc_library(
    name = "zmq",
    srcs = ["libzmq.so"],
    visibility = ["//visibility:public"],
)
""",
)
