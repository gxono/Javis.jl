"""
    Frames

Stores the actual computed frames and the user input
which can be `:same` or `RFrames(10)`.
The `frames` are computed in [`render`](@ref).
"""
mutable struct Frames{T}
    frames::Union{Nothing,UnitRange}
    user::T
end

Base.convert(::Type{Frames}, x) = Frames(nothing, x)
Base.convert(::Type{Frames}, x::Frames) = x
Base.convert(::Type{Frames}, x::UnitRange) = Frames(x, x)

Base.copy(f::Frames) = Frames(f.frames, f.user)

"""
    set_frames!(parent, elem, last_frames::UnitRange; is_first=false)

Compute the frames based on a.frames and `last_frames`.
Save the result in `a.frames.frames` which can be accessed via [`get_frames`](@ref).

# Arguments
- `parent` is either nothing or the Object for the Action
- `elem` is the Object or Action
- `last_frames` holds the frames of the previous object or action.
- `is_first` defines whether this is the first child of the parent (for actions)
"""
function set_frames!(parent, elem, last_frames::UnitRange; is_first = false)
    frames = elem.frames.user
    elem.frames.frames = get_frames(parent, elem, frames, last_frames; is_first = is_first)
end

"""
    get_frames(elem)

Return `elem.frames.frames` which holds the computed frames for the AbstractObject or AbstractAction `a`.
"""
function get_frames(elem)
    elem.frames.frames
end


"""
    get_frames(parent, elem, frames::Symbol, last_frames::UnitRange; is_first=false)

Get the frames based on a symbol defined in `FRAMES_SYMBOL` and the `last_frames`.
Throw `ArgumentError` if symbol is unknown
"""
function get_frames(parent, elem, frames::Symbol, last_frames::UnitRange; is_first = false)
    if frames === :same
        if elem isa AbstractAction && is_first
            return 1:length(last_frames)
        end
        return last_frames
    elseif frames === :all
        return 1:maximum(CURRENT_VIDEO[1].background_frames)
    else
        backtick_frame_symbol = map(x -> "`:$x`", FRAMES_SYMBOL)
        allowed_frames_str = join(backtick_frame_symbol, ", ", " and ")
        err_msg = "Currently the only symbols supported for defining frames are $allowed_frames_str."
        throw(ArgumentError(err_msg))
    end
end

"""
    get_frames(parent, elem, relative::RFrames, last_frames::UnitRange; is_first=false)

Return the frames based on a relative frames [`RFrames`](@ref) object and the `last_frames`.
"""
function get_frames(
    parent,
    elem,
    relative::RFrames,
    last_frames::UnitRange;
    is_first = false,
)
    # don't take the `last_frames` from the parent as this doesn't make sense
    if is_first
        return relative.frames
    end
    start_frame = last(last_frames) + first(relative.frames)
    last_frame = last(last_frames) + last(relative.frames)
    return start_frame:last_frame
end


"""
    get_frames(parent, elem, glob::GFrames, last_frames::UnitRange)

Return the frames based on a global frames [`GFrames`](@ref) object and the `last_frames`.
If `is_action` is false this is the same as defining the frames as just a unit range.
Inside an action it's now defined globally though.
"""
function get_frames(parent, elem, glob::GFrames, last_frames::UnitRange; is_first = false)
    if elem isa AbstractAction
        return glob.frames .- first(get_frames(parent)) .+ 1
    end
    return glob.frames
end

"""
    function get_frames(parent, elem, func_frames::Function, last_frames::UnitRange; is_first = false)

Return the frames based on a specified function. The function `func_frames` is simply evaluated 
"""
function get_frames(
    parent,
    elem,
    func_frames::Function,
    last_frames::UnitRange;
    is_first = false,
)
    return func_frames()
end

"""
    prev_start()

The start frame of the previous object or for an action the start frame of the parental object.
Can be used to provide frame ranges like:
```
@Frames(prev_start(), 10)
```
"""
function prev_start()
    if CURRENT_OBJECT_ACTION_TYPE[1] == :Object
        PREVIOUS_OBJECT[1].frames.frames[1]
    else
        PREVIOUS_ACTION[1].frames.frames[1]
    end
end

"""
    prev_end()

The end frame of the previous object or for an action the end frame of the parental object.
Can be used to provide frame ranges like:
```
@Frames(prev_end()-10, 10)
```
"""
function prev_end()
    if CURRENT_OBJECT_ACTION_TYPE[1] == :Object
        PREVIOUS_OBJECT[1].frames.frames[end]
    else
        PREVIOUS_ACTION[1].frames.frames[end]
    end
end

"""
    startof(oa::Union{Action,Object})

The (already computed) first frame of `oa`. Can be used together with [`@Frames`](@ref) to
define a frame range relative to a specific object or action rather than the immediately
preceding one (which [`prev_start`](@ref) refers to):
```julia
@Frames(startof(some_earlier_object) + 5, 10)
```
"""
startof(oa::Union{AbstractAction,AbstractObject}) = oa.frames.frames[1]

"""
    endof(oa::Union{Action,Object})

The (already computed) last frame of `oa`. See [`startof`](@ref).
"""
endof(oa::Union{AbstractAction,AbstractObject}) = oa.frames.frames[end]

"""
    global_end()

The last frame of the whole video, i.e. how many frames it has in total (the same count
`render` uses for the `:all` frames symbol). Requires at least one [`Background`](@ref) to
already be defined, same as `:all`.

Combined with [`@Frames`](@ref), this lets you define frame ranges as a percentage of the
video's total length instead of a hardcoded frame count, so scaling a whole animation up or
down (e.g. from 100 frames to 500) doesn't require rewriting every object's frame range:
```julia
Object(@Frames(0.25 * global_end(), stop = 0.75 * global_end()), ...)
```
Non-integer results are rounded to the nearest frame.
"""
function global_end()
    maximum(CURRENT_VIDEO[1].background_frames)
end

_frame_round(x) = round(Int, x)

"""
    @Frames(start, len)
    @Frames(start, stop=)

Can be used to define frames using functions like [`prev_start`](@ref), [`prev_end`](@ref) or
[`global_end`](@ref). `start`/`stop` are rounded to the nearest frame if they don't evaluate
to an integer already, so percentage-based expressions like `0.25 * global_end()` work.

# Example
```julia
red_circ = Object(1:90, (args...)->circ("red"))
blue_circ = Object(@Frames(prev_start()+20, 70), (args...)->circ("blue"))
blue_circ = Object(@Frames(prev_start()+20, stop=90), (args...)->circ("blue"))
```
is the same as
```julia
red_circ = Object(1:90, (args...)->circ("red"))
blue_circ = Object(21:90, (args...)->circ("blue"))
blue_circ = Object(41:90, (args...)->circ("blue"))
```

Frames as a percentage of the whole video, regardless of its total frame count:
```julia
blue_circ = Object(@Frames(0.25 * global_end(), stop = 0.75 * global_end()), (args...)->circ("blue"))
```
"""
macro Frames(start, in_args...)
    args = []
    kwargs = Pair{Symbol,Any}[]
    kwarg_symbols = Symbol[]
    for el in in_args
        if Meta.isexpr(el, :(=))
            push!(kwargs, Pair(el.args...))
            push!(kwarg_symbols, el.args[1])
        else
            push!(args, el)
        end
    end
    stop_idx = findfirst(==(:stop), kwarg_symbols)
    if stop_idx !== nothing
        stop = kwargs[stop_idx][2]
        return esc(
            quote
                Javis.Frames(
                    nothing,
                    () -> Javis._frame_round($start):Javis._frame_round($stop),
                )
            end,
        )
    elseif isempty(kwarg_symbols)
        esc(quote
            Javis.Frames(nothing, () -> begin
                s = Javis._frame_round($start)
                s:(s + $(args[1]) - 1)
            end)
        end)
    end
end
