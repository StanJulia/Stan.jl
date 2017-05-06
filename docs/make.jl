using Documenter, Stan
makedocs(
    format = :html,
    sitename = "Stan",
    pages = Any[
        "Introduction" => "INTRO.md",
        "Getting started" => "GETTINGSTARTED.md",
        "Example walkthrough" => "WALKTHROUGH.md",
        "Examples" => "EXAMPLES.md",
        "Versions" => "VERSIONS.md",
        "Stan.jl documentation" => "index.md",
    ]
)

deploydocs(
    repo = "github.com/goedman/Stan.jl.git",
    target = "build",
    julia = "0.5",
    osname = "linux",
    deps = nothing,
    make = nothing
)