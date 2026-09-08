# Javis.jl - Changelog

# PR changes
- Added `global_end()` and taught `@Frames` to round non-integer results, so frame ranges
  can be defined as a percentage of the whole video: `@Frames(0.25 * global_end(), stop =
  0.75 * global_end())` covers the middle half regardless of the video's total frame count
  (closes #239).
- Clarified that `rotate_around`/`anim_rotate_around`'s point is an absolute/canvas
  coordinate, not relative to the rotating object's own position (closes #471). Documented
  that translations (and their effect on a later morph's starting position) persist across
  subsequent actions on the same object unless explicitly reversed (JuliaAnimators/Javis.jl#369).
- Fixed `follow_path` for objects with a non-origin `start_pos`, which previously drifted
  off the intended path (closes #491).
- Fixed the `Luxor` module leaking into any caller's scope via `using Javis`, caused by a
  blind re-export loop that also picked up every module's implicit self-binding
  (closes #489). That same fix surfaced a second bug it had been masking: `@scale_layer`
  relied on `Luxor` being in scope at the macro *call site*, not just Javis's own scope.
- Fixed mp4 rendering silently keeping only the first frame: `render` wrote an `IOBuffer`'s
  over-allocated backing array (`io.data`) to ffmpeg's stdin instead of just the bytes
  written for that frame, appending garbage after each frame's PNG.
- Fixed calls to Luxor internals renamed with a leading underscore in Luxor 3.x
  (`get_current_redvalue` etc.), which broke every draw call needing the current color
  (fill/stroke overrides, morphing, partial drawing, postprocessing, ...).
- Fixed a `ProgressMeter` deprecation warning on every `render()` call (from the old
  positional `@showprogress` syntax) that was failing any `@test_logs (:warn,)`-style test.
- Fixed an `UndefVarError` in keyframed morphs caused by a `frame`/`rel_frame` typo.
- Fixed `cancel_stream()` crashing instead of being a no-op when the streaming process it
  found already exited by the time it tried to kill it (a `ps`/`grep` race, observed on
  macOS CI).
- Bumped `Hungarian` and `Images` compat to their latest releases (0.7 and 0.26
  respectively); everything else's existing bound already covered the newest version.
- Fixed 2 flaky `@test_reference` image comparisons that were failing on sub-pixel
  anti-aliasing drift rather than an actual rendering bug (one used exact `==` instead of
  the tolerant `psnr_equality()` every sibling test uses; the other's reference PNGs were
  regenerated against the current, verified-correct rendering pipeline).
- Fixed the project's CI: a hard-failing `actions/cache@v1` was taking down the entire test
  matrix, the Documentation job couldn't deploy to GitHub Pages from a fork (custom
  secrets aren't passed to fork workflows regardless of trigger - switched to the default
  `GITHUB_TOKEN` with `contents: write` instead of an SSH deploy key), macOS jobs broke
  after bumping `setup-julia` to v3 (its arch validation rejects hardcoded `x64` on Apple
  Silicon runners - switched to `arch: default`), and `format-check` was reformatting
  already-compliant files because it floated to JuliaFormatter's newest major version
  (pinned to the 1.x line the codebase is actually formatted for).
- **Breaking:** migrated to Luxor 4.x, dropping Luxor 3.x support (`Luxor = "4"`).
  - `sethue()` (the zero-argument Action-animator helper, e.g.
    `Action(1:150, color_anim, sethue())`) is renamed to **`sethue_anim()`**. Luxor 4.0
    added its own zero-argument `sethue()` (a getter for the current color) which collides
    with the old name/meaning. Update any animation using `sethue()` this way to
    `sethue_anim()`.
  - Luxor 4.0 also removed `Point +/- Number` scalar arithmetic (e.g. `O - 50`). Javis's own
    `src/` never relied on this, but update your own scripts if they do.
- Moved the Gtk-based live viewer (`liveview=true` outside Jupyter/Pluto) into a package
  extension (`JavisGtkViewerExt`). `Gtk` and `GtkReactive` are now weak/optional
  dependencies: `using Javis` no longer requires them, only `using Gtk, GtkReactive` before
  calling `render(...; liveview=true)`. Fixes install/precompile issues on headless setups.
  **Known limitation:** `GtkReactive` caps `IntervalSets` at `0.3-0.5` upstream (unfixed even
  on its unreleased master) and currently cannot resolve alongside a modern `Images.jl`
  (which needs `IntervalSets >= 0.7`), so adding `GtkReactive` into a Javis environment fails
  today regardless of this change. The `test/viewer.jl` Gtk testset is therefore excluded
  from `Pkg.test()` for now; it's kept as a spec for the extension. Everything else
  (rendering, animations, morphs, latex, layers, livestreaming) is unaffected.
- Removed the unused `Interact` dependency (dead code, no longer referenced anywhere).
- Raised minimum Julia version to 1.9 (required for package extensions).
- changed render method for mp4 to use ffmpeg directly inplace of VideoIO
- Added jpaths a field in Object that is useful for morphs and partial drawing
- Added morphs to arbitrary objects and functions.
- Keyframed morphs with Animations.jl are possible.
- Added ability to partially draw any object, and have animations of showing them get created.
- One tutorial added on how to use morphs
- tutorial on partial draw / show creation 
- Few tests for morphs added
- test for partial draw/ show creation

## v0.9.0 (26th of May 2022)
- Ability to use Luxor functionality without rendering an animation
- Fix `info_box` function definition in Tutorial 6
- Fix inconsistencies in tutorial 2
- Add example for Chaos Game
- Add overload for keyword arguments to `latex()` function
- Change font scaling in `svg2luxor` from 1/2 to 425/1000
- Change default line width to 2.0 like Luxor 

## v0.8.0 (1st of February 2022)
- Allow Luxor v3.0
- moved notebooks to extra repository [JavisNB](https://github.com/JuliaAnimators/JavisNB.jl)

## v0.7.2 (2nd of January 2022)
- Fix bug that would make frames <= 0 throw error
- Allow integer and irrational angles in rotation
- Compat: Allow Images v0.25
- Compat: Allow ImageIO v0.6

## v0.7.1 (28th of September 2021)
- added `scale_linear` function to easily scale values or points
- added `@scale_layer` to transform a layer based on a given linear scale
- Add `postprocessing_frames_flow` and `postprocessing_frame` keyword arguments to `render`

## v0.7.0 (19th of September 2021)
- Support for VideoIO v0.9 
  - dropping support for v0.6-v0.8
  - dropping support for Julia v1.4

## v0.6.4 (19th of September 2021)
- Added fix to `latex` function to make it work on Windows

## v0.6.3 (17th of September 2021)
- `RFrames` is ignored when used in the first `Action` of an `Object`
- Added layers tutorial
- Added fix that allows to use several `act!` on a `Layer` without strange behavior

## v0.6.2 (12th of August 2021)
- added `@Frames` macro for full power mode of defining frames
- bugfix in `@JLayer` when dimensions are not defined explicitly
- allow color interpolation in `change`
- bugfix `color` can be a non string value in `JBox`

## v0.6.1 (7th of August 2021)
- Add shorthands for basic shapes
  - New functions `JBox, JCircle, JEllipse, JLine, JPoly, JRect, JStar, @JShape` 
- added support for `rescale_factor` keyword in `render` function
- Docstring improvements to `translate`

## v0.6.0 (3rd of August 2021)
- Added layers see `@JLayer`

## v0.5.3 (26th of July 2021)
- Allow all kinds of iterable ways in the `act!` function such that `act!(::Matrix, ::Action)` also works
- Updated `anim_translate`
  - Docstring: `anim_translate` translates by a vector instead of to a point
  - from->to assumes that we are at `from` already instead of adding it to it
- Morphing mutates the object function 

## v0.5.2
- added support for local network live streaming

## v0.5.1
- added support for Pluto notebooks
- add alignment options to latex rendering
- clarified `O` as origin in tutorial 1

## v0.5.0 (29th of March 2021)
- `:all` can now be used to have an Object persist for all frames of an animation
- added support for Jupyter notebooks

## v0.4.0 (9th of January 2021)
- added ImageIO and ImageMagick as dependencies

## v0.3.4 (23rd of December 2020)
- Bugfix: `get_latex_svg` assumed a `LaTeXString` always includes `$$`
- changed color palette for gif rendering

## v0.3.3 (2nd of December 2020)
- `change` can now set a value 
- Bugfix: reset keywords if `; keep=false`

## v0.3.2 (24th of November 2020)
- added `ffmpeg_loglevel` option for debugging purposes

## v0.3.1 (18th of November 2020)
- removed `ColorTypes` as a dependency
- docstring fixes for `morph_to`

## v0.3 (10th of November 2020)
- Morphing with several shapes
- Changed `Action` to `Object` syntax
- Ability to use `setopactity()` in an `Action`
- Ability to disable an `Action` after its last defined frame. See `? Action` and the keyword `; keep`
- Moved from `Translation`, `Scaling` and `Rotation` to `anim_translate` etc
- Changed `Rel` to `RFrames` and added `GFrames` for defining actions with global frames
- A warning is shown if some frames don't have a background
- A warning is shown if an `Action` is defined outside the parental `Object`

## v0.2.2 (20th of October 2020)
- Ability to change a keyword using `change`

## v0.2.1 (11th of October 2020)
- Ability to draw animated LaTeX via `appear(:draw_text)`
- Support for Images v0.23
- various documentation updates

## 0.2.0 (25th of September 2020)
- Ability to use [Animations.jl](https://github.com/jkrumbiegel/Animations.jl) 
  - for Transformations and `appear` and `disappear`
- Show progress of rendering using [ProgressMeter.jl](https://github.com/timholy/ProgressMeter.jl)
- Use [VideoIO](https://github.com/JuliaIO/VideoIO.jl) for faster rendering without temporary images
- Ability to draw animated text via `appear(:draw_text)`
  - Must be called inside a `SubAction` 
- Ability to morph with `fill` or `stroke` and using `SubAction` to specify changes in color
- Added live viewer based on `Gtk.jl` in the `javis` function
  - Activate in `javis` by setting `liveview = true`
- Prototype returning single frame of Javis animation with `get_javis_frame`
  - Currently must be invoked after `javis` function call
  - Can be called via `Javis.get_javis_frame` as it is not exported yet
- An object described by an action can follow a path (a vector of points). See `follow_path`
- Bugfix when scaling to 0. Before this every object on that frame would disappear even in a different layer
- Bugfix in interpolation: Interpolation of a single frame like `1:1` returns `1.0` now instead of `NaN`.

## 0.1.5 (14th of September 2020)
- Bugfix in svg parser when a layer gets both transformed and scaled

## 0.1.4 (13th of September 2020)
- Bugfix in svg parser when a reflected Bézier curve followed a move operation

### Removed
- `latex` no longer takes the `fontsize` as an argument [PR #180](https://github.com/JuliaAnimatorsJuliaAnimators/Javis.jl/pull/180)

## 0.1.3 (11th of September 2020)
- First `SubAction` for an `Action` no longer requires explicit frame range and will default to the frames of the `Action`
- Ability to scale an object with `Scaling`. Works similar to `Translation` and `Rotation` 
- Added JuliaFormatter GitHub Action
- Updated Contributing guidelines
- Added `.JuliaFormatter.toml` for automatic formatting

## 0.1.2 (24th of August 2020)
- Added capabilities for generating `.mp4` files
- Updated testing scheme for `Javis.jl`

## 0.1.1 (21st of August 2020)
- Define frames in `SubAction` with `Rel` and `Symbol`
- `latex` now uses font size specified with `fontsize`
- Ability to access font size with `get_fontsize`

## 0.1.0 (19th of August 2020)
Initial implementation with
- `BackgroundAction`, `Action` and `SubAction`
- frames for `Action` can be defined using a `UnitRange`, `Symbol` or `Rel`
- `Translation`, `Rotation` 
- `appear`/`disappear` using opacity and linewidth in `SubAction`
- render `latex` using a basic svg parser
