def _uniq(iterable):
    """Remove duplicates from a list."""

    unique_elements = {element: None for element in iterable}
    return unique_elements.keys()

def cc_champion(name, srcs):
    """Build a cc champion"""
    if not (name.startswith("lib") and name.endswith(".so")):
        fail("Champions must be named libNAME.so")

    native.cc_binary(
        name = name,
        srcs = srcs,
        deps = [":prologin"],  # TODO(halfr): remove implicit dependency
        linkopts = ["-ldl"],
        linkshared = True,
    )

def stechec2_config(name, game, champions, extra_config_content = None, replay = ""):
    rules = "//games:{}.so".format(game)

    config_content = """
server: $(rootpath //:server)
client: $(rootpath //:client)
rules: $(rootpath {rules})
clients: [{clients}]
verbose: 0
""".format(
        rules = rules,
        clients = ",".join(["$(rootpath {})".format(champion) for champion in champions]),
    )

    if extra_config_content:
        config_content += extra_config_content.strip() + "\n"
    if replay:
        config_content += "replay: " + replay

    native.genrule(
        name = name + "_gen",
        srcs = [
            "//:client",
            "//:server",
            rules,
        ] + _uniq(champions),
        outs = [name],
        cmd = """cat << EOF > $@
{}
EOF
""".format(config_content),
    )

def e2e_test(name, game, champions, expected_output):
    rules = "//games:{}.so".format(game)

    native.genrule(
        name = name + "expected_results_gen",
        outs = [name + "_expected_results"],
        cmd = """cat << EOF > $@
{}
EOF
""".format(expected_output.strip()),
    )

    stechec2_config(name + "_config", game, champions)

    native.sh_test(
        name = name,
        srcs = ["//tools:e2e_test.sh"],
        data = [
            "//tools:stechec2-run",
            ":{}_expected_results".format(name),
            "//:client",
            "//:server",
            name + "_config",
            rules,
        ] + _uniq(champions),
        args = [
            "$(location //tools:stechec2-run)",
            "$(location :{}_config)".format(name),
            "$(location :{}_expected_results)".format(name),
        ],
    )

def stechec2_match(name, game, champions):
    rules = "//games:{}.so".format(game)

    stechec2_config(name + "_config", game, champions)

    native.sh_binary(
        name = name,
        srcs = ["//tools:stechec2-run.sh"],
        data = [
            "//tools:stechec2-run",
            "//:client",
            "//:server",
            name + "_config",
            rules,
        ] + _uniq(champions),
        args = [
            "$(location //tools:stechec2-run)",
            "$(location :{}_config)".format(name),
        ],
    )

def replay_test(name, game, champions):
    rules = "//games:{}.so".format(game)
    replay = name + "_replay"

    stechec2_config(name + "_config", game, champions, replay = replay)

    native.sh_test(
        name = name,
        srcs = ["//tools:replay_test.sh"],
        data = [
            "//tools:stechec2-run",
            "//:client",
            "//:server",
            "//:replay",
            name + "_config",
            rules,
        ] + _uniq(champions),
        args = [
            "$(location :{}_config)".format(name),
            replay,
            "$(location {})".format(rules),
        ],
        deps = ["@bazel_tools//tools/bash/runfiles"],
    )
