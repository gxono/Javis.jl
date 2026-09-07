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

deploydocs(;
    repo = "github.com/gxono/Javis.jl",
    push_preview = true,
    devbranch = "main",
)
