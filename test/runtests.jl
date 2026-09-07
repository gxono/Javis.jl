using Animations
using Images
using Javis
import Latexify: latexify
using LaTeXStrings
using ReferenceTests
using Test
using VideoIO

function ground(video, action, framenumber)
    background("white")
    sethue("blue")
    return framenumber
end

function ground_black_on_white(video, action, framenumber)
    background("white")
    sethue("black")
    return framenumber
end

function ground_color(color_bg, color_pen, framenumber)
    background(color_bg)
    sethue(color_pen)
    return framenumber
end

function circle_with_color(position, radius, action, color)
    sethue(color)
    circle(position, radius, action)
end

@testset "Javis" begin
    @testset "Unit" begin
        include("unit.jl")
    end
    @testset "SVG LaTeX tests" begin
        include("svg.jl")
    end
    @testset "Animations" begin
        include("animations.jl")
    end
    @testset "Morphing" begin
        include("morphing.jl")
    end
    @testset "Shorthands" begin
        include("shorthands.jl")
    end
    @testset "Layers" begin
        include("layers.jl")
    end
    @testset "Partial Drawing" begin
        include("partialdrawtest.jl")
    end
    @testset "Postprocessing" begin
        include("postprocessing.jl")
    end
    @testset "Livestreaming" begin
        include("livestream.jl")
    end
    # The Gtk-based live viewer (test/viewer.jl, JavisGtkViewerExt) is not tested
    # here: GtkReactive is capped at IntervalSets 0.3-0.5 upstream and cannot
    # resolve in the same environment as a modern Images.jl. See CHANGELOG.md
    # and test/Project.toml. Re-enable once that's resolved upstream, or once
    # the extension is rewritten without a GtkReactive dependency.
end
