using Javis
using Documenter

makedocs(;
    modules = [Javis],
    authors = "Ole Kröger <o.kroeger@opensourc.es> and contributors",
    repo = Documenter.Remotes.GitHub("gxono", "Javis.jl"),
    sitename = "Javis.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://gxono.github.io/Javis.jl",
        assets = String[],
        edit_link = "main",
        # references.md re-exports (and documents) Luxor's entire public API on top of
        # Javis's own, so it's inherently large - it was already within ~1KiB of
        # Documenter's default 200KiB hard limit before this option was added, meaning
        # any future docstring addition could turn a warning into a build failure.
        size_threshold_ignore = ["references.md"],
    ),
    pages = [
        "Home" => "index.md",
        "Tutorials" => [
            "tutorials.md",
            "tutorials/tutorial_1.md",
            "tutorials/tutorial_2.md",
            "tutorials/tutorial_3.md",
            "tutorials/tutorial_4.md",
            "tutorials/tutorial_5.md",
            "tutorials/tutorial_6.md",
            "tutorials/tutorial_7.md",
            "tutorials/tutorial_8.md",
            "tutorials/tutorial_morphing.md",
            "tutorials/tutorial_partialdraw.md",
        ],
        "HowTo" => "howto.md",
        "Workflows" => "workflows.md",
        "Examples" => "examples.md",
        "Mission" => "mission.md",
        "References" => "references.md",
        "Contributing" => "contributing.md",
    ],
)

deploydocs(; repo = "github.com/gxono/Javis.jl", push_preview = true, devbranch = "main")
