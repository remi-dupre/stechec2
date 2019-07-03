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

def stechec2_map(name, map_content):
    native.genrule(
        name = name + "_map_gen",
        outs = [name + "_map"],
        cmd = """cat << EOF > $@
{}
EOF
""".format(map_content),
    )

    return [":" + name + "_map"]

def stechec2_config(name, game, champions, extra_config_content = None, replay = "", map_content = ""):
    rules = "//games:{}.so".format(game)

    config_srcs = [
        "//:client",
        "//:server",
        rules,
    ] + _uniq(champions)

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
        config_content += "replay: " + replay + "\n"
    if map_content:
        config_content += "map: $(rootpath :{})\n".format(name + "_map")
        config_srcs.extend(stechec2_map(name, map_content))

    native.genrule(
        name = name + "_gen",
        srcs = config_srcs,
        outs = [name],
        cmd = """cat << EOF > $@
{}
EOF
""".format(config_content),
    )

    return [":" + name] + config_srcs

def e2e_test(name, game, champions, expected_output, map_content = ""):
    rules = "//games:{}.so".format(game)

    native.genrule(
        name = name + "_expected_results_gen",
        outs = [name + "_expected_results"],
        cmd = """cat << EOF > $@
{}
EOF
""".format(expected_output.strip()),
    )

    config_data = stechec2_config(name + "_config", game, champions, map_content = map_content)

    native.sh_test(
        name = name,
        srcs = ["//tools:e2e_test.sh"],
        data = [
            "//tools:stechec2-run",
            ":{}_expected_results".format(name),
        ] + config_data,
        args = [
            "$(location //tools:stechec2-run)",
            "$(location :{}_config)".format(name),
            "$(location :{}_expected_results)".format(name),
        ],
    )

def stechec2_match(name, game, champions, map_content = ""):
    rules = "//games:{}.so".format(game)

    config_data = stechec2_config(name + "_config", game, champions, map_content = map_content)

    native.sh_binary(
        name = name,
        srcs = ["//tools:stechec2-run.sh"],
        data = ["//tools:stechec2-run"] + config_data,
        args = [
            "$(location //tools:stechec2-run)",
            "$(location :{}_config)".format(name),
        ],
    )

def replay_test(name, game, champions, map_content = ""):
    rules = "//games:{}.so".format(game)
    replay = name + "_replay"

    config_data = stechec2_config(name + "_config", game, champions, replay = replay, map_content = map_content)

    native.sh_test(
        name = name,
        srcs = ["//tools:replay_test.sh"],
        data = [
            "//tools:stechec2-run",
            "//:replay",
        ] + config_data,
        args = ["$(location :{}_config)".format(name)],
        deps = ["@bazel_tools//tools/bash/runfiles"],
    )
