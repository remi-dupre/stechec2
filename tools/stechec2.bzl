def _uniq(iterable):
    """Remove duplicates from a list."""

    unique_elements = {element: None for element in iterable}
    return unique_elements.keys()

def cc_champion(name, srcs):
    if not (name.startswith("lib") and name.endswith(".so")):
        fail("Champions must be named libNAME.so")

    native.cc_binary(
        name = name,
        srcs = srcs,
        deps = [":prologin"],
        linkopts = ["-ldl"],
        linkshared = True,
    )

def stechec2_run(name, game, champions, extra_config_content = None, replay = False):
    rules = "//games:{}.so".format(game)
    config_content = """
server: $(location //:server)
client: $(location //:client)
rules: $(location {rules})
clients: [{clients}]
verbose: 0
""".format(
        rules = rules,
        clients = ",".join(["$(location {})".format(champion) for champion in champions]),
    )

    if extra_config_content:
        config_content += extra_config_content.strip() + "\n"
    if replay:
        config_content += "replay: $(location :{}_replay)\n".format(name)

    results_path = name + "_results"
    native.genrule(
        name = name,
        srcs = [
            "//:client",
            "//:server",
            rules,
        ] + _uniq(champions),
        outs = [results_path] + ([name + "_replay"] if replay else []),
        tools = ["//tools:stechec2-run"],
        local = True,
        cmd = """cat <<EOF > config.yml && $(location //tools:stechec2-run) --quiet config.yml > $(location :{})
{}
EOF
""".format(results_path, config_content),
    )

def e2e_test(name, game, champions, expected_output):
    native.genrule(
        name = name + "expected_results_gen",
        outs = [name + "_expected_results"],
        cmd = """cat > $@ <<EOF
{}
EOF
""".format(expected_output.strip()),
    )

    stechec2_run(name + "_match", game, champions)

    native.sh_test(
        name = name,
        srcs = ["//tools:e2e_test.sh"],
        data = [
            ":{}_expected_results".format(name),
            ":{}_match_results".format(name),
        ],
        args = [
            "$(location :{}_expected_results)".format(name),
            "$(location :{}_match_results)".format(name),
        ],
    )

def stechec2_replay(name, game, replay):
    rules = "//games:{}.so".format(game)
    native.genrule(
        name = name + "_sh_gen",
        srcs = ["//tools:stechec2_replay.sh.tpl", replay],
        outs = [name + ".sh"],
        cmd = "sed -e s@RULES@{}@ -e s@REPLAY@$(rootpath {})@ $(location //tools:stechec2_replay.sh.tpl) > $@".format(game, replay),
    )

    native.sh_binary(
        name = name,
        srcs = [name + ".sh"],
        data = [
            "//:replay",
            rules,
            replay,
        ],
        deps = ["@bazel_tools//tools/bash/runfiles"],
    )
