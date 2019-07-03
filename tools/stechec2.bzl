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

def stechec2_run(name, game, champions, extra_config_content = ""):
    config_name = "{}_config".format(name)

    native.genrule(
        name = "{}_config_gen".format(name),
        srcs = [
            "//:client",
            "//:server",
            "//games:{}.so".format(game),
        ] + _uniq(champions),
        outs = [config_name],
        cmd = """cat > $@ <<EOF
server: $(location //:server)
client: $(location //:client)
rules: $(location {rules})
clients: [{clients}]
verbose: 0
{extra_config}
EOF
""".format(
            rules = "//games:{}.so".format(game),
            clients = ",".join(["$(location {})".format(champion) for champion in champions]),
            extra_config = extra_config_content.strip(),
        ),
    )

    results_path = name + "_results"
    native.genrule(
        name = name,
        srcs = [
            ":" + config_name,
            "//:client",
            "//:server",
            "//games:{}.so".format(game),
        ] + _uniq(champions),
        outs = [results_path],
        cmd = "$(location //tools:stechec2-run) --quiet $(location :{}) > $@".format(config_name),
        tools = ["//tools:stechec2-run"],
        local = True,
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
