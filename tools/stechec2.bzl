def _uniq(iterable):
    """Remove duplicates from a list."""

    unique_elements = {element: None for element in iterable}
    return unique_elements.keys()

def e2e_test(name, game, champions, expected_output):
    output = "{}_expected_output".format(name)
    native.genrule(
        name = output,
        outs = ["{}_expected_output.log".format(name)],
        cmd = """cat > $@ <<EOF
{}
EOF
""".format(expected_output.strip()),
    )

    native.sh_test(
        name = name,
        srcs = ["//tools:e2e_test.sh"],
        args = [
            "$(location //:server)",
            "$(location //:client)",
            "$(location //games:{}.so)".format(game),
            "$(location :{})".format(output),
        ] + ["$(location {})".format(champion) for champion in champions],
        data = [
            ":{}".format(output),
            "//:client",
            "//:server",
            "//games:{}.so".format(game),
        ] + _uniq(champions),
    )

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
