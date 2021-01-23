"""
`format(str::AbstractString, args...) -> String`

format `str` with `args`
"""
function format(str::AbstractString, args...)
    # TODO: do replacements in fmtstr
    # getattr and getindex

    inbetweens, field_names, fmt_specs = parse_original_string(str)

    arg_idxs = Int[]

    if isempty(field_names) || isempty(field_names[1]) # automatic numbering
        all(map(isempty, field_names)) || error("cannot switch from manual field specification to automatic field numbering")
        arg_idxs = collect(1:length(field_names))
    else # manual numbering
        for field_name in field_names
            isempty(field_name) && error("cannot switch from manual field specification to automatic field numbering")
            push!(arg_idxs, parse(Int, field_name))
        end
    end

    ordered_args = args[arg_idxs]

    parsed_fmt_specs = tuple((parse_fmt_spec(fmt_specs[i], arg) for (i, arg) in enumerate(ordered_args))...)

    combine(inbetweens, parsed_fmt_specs, ordered_args)
end

function parse_original_string(str::AbstractString)
    inbetweens = String[]
    fmt_specs = String[]
    field_names = String[]
    field = ""
    nextidx = 1
    while field !== nothing
        nextidx, inbetween, field = iterate_brackets_pair(str, nextidx)

        push!(inbetweens, inbetween)

        if field !== nothing
            temp = split(field, ':', limit=2)
            field_name = temp[1]
            fmt_spec = length(temp) == 2 ? temp[2] : ""

            push!(field_names, field_name)
            push!(fmt_specs, fmt_spec)
        end
    end
    (inbetweens, field_names, fmt_specs)
end

"""
`iterate_brackets_pair(str, start) -> (nextidx, inbetween, field)`

return index up to where `str` has been analysed,
in-between string,
the format string or nothing if no brackets have been found
"""
function iterate_brackets_pair(str, start)
    i = start
    found = false
    while i <= lastindex(str)
        if str[i] == '}'
            if i == lastindex(str) || str[i + 1] != '}'
                error("single '}' is not allowed at idx $i in string \"$str\"")
            else
                i = nextind(str, i + 1)
                continue
            end
        end

        if str[i] == '{'
            if i == lastindex(str)
                error("single '{' is not allowed at idx $i in string \"$str\"")
            elseif str[i + 1] == '{'
                i = nextind(str, i + 1)
                continue
            else
                found = true
                break
            end
        end

        i = nextind(str, i)
    end

    count = 1
    j = i + 1
    while j <= lastindex(str)
        if str[j] == '{'
            count += 1
        elseif str[j] == '}'
            count -= 1
        end
        if count == 0
            break
        end
        j = nextind(str, j)
    end

    if count != 0 && found
        error("braces missmatch: \"$(str[i:end])\" at idx $i")
    end
    (
        j + 1,
        replace(replace(str[start:prevind(str, i)], "{{" => "{"), "}}" => "}"),
        found ? str[i + 1:prevind(str,j)] : nothing
    )
end


"""
`parse_fmt_spec(fmt_spec::String, arg)`

parse the format specifier.
"""
parse_fmt_spec(fmt_spec::String, arg) = fmt_spec


"""
`fmt(fmt_spec, x)`

return `x` formated according to `fmt_spec`

This function is called by format and can be overloaded to add suport for diferent types.

Defaults to calling string on the object.
"""
fmt(fmt_spec, x) = string(x)


# TODO: look at unrolled.jl for performance?
"""

"""
function combine(inbetweens, fmt_specs, args)
    result = ""
    for (inbetween, fmt_spec, arg) in zip(inbetweens, fmt_specs, args)
        result *= inbetween * fmt(fmt_spec, arg)
    end
    result * inbetweens[end]
end
