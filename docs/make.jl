using Documenter, Stan
makedocs(
    format = :html,
    sitename = "Stan",
    pages = Any[
        "Introduction" => "INTRO.md",
        "Installation" => "INSTALLATION.md",
        "Walkthrough" => "WALKTHROUGH.md",
        "Versions" => "VERSIONS.md",
        "Stan.jl documentation" => "index.md",
    ]
)

deploydocs(
    repo = "github.com/StanJulia/Stan.jl.git",
    target = "build",
    julia = "1.0",
    osname = "linux",
    deps = nothing,
    make = nothing
)