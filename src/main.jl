"""
`format(str::AbstractString, args...) -> String`

format `str` with `args`
"""
function format(str::AbstractString, args...)
    inbetweens = String[]
    fields = String[]
    field = ""
    nextidx = 1
    while field !== nothing
        nextidx, inbetween, field = iterate_braces_pair(str, nextidx)

        push!(inbetweens, inbetween)
        if field !== nothing
            push!(fields, field)
        end
    end

    # TODO: do replacements in fmtstr
    # getattr and getindex

    arg_idxs = Int[]
    fmt_specs = String[]

    automatic_numbering = false
    manual_numbering = false

    for (i, field) in enumerate(fields)
        idx = findfirst(':', field)
        if idx === nothing
            field_name = field
            fmt_spec = ""
        else
            field_name = field[1:(idx - 1)]
            fmt_spec = field[(idx + 1):end]
        end

        push!(fmt_specs, fmt_spec)

        if isempty(field_name)
            manual_numbering && error("cannot switch from manual field specification to automatic field numbering")
            automatic_numbering = true
            push!(arg_idxs, i)
        else
            automatic_numbering && error("cannot switch from manual field specification to automatic field numbering")
            manual_numbering = true
            push!(arg_idxs, parse(Int, field_name))
        end
    end
    
    ordered_args = args[arg_idxs]

    replacement_fields = tuple([(parse_fmt_spec(fmt_specs[i], arg), arg) for (i, arg) in enumerate(ordered_args)]...)

    combine(inbetweens, replacement_fields)
end


"""
`iterate_braces_pair(str, start)`

return end of analysed string, in-between string and the format string
"""
function iterate_braces_pair(str, start)
    i = start
    while i <= lastindex(str)
        if str[i] == '}'
            if i == lastindex(str)
                error("single '}' is not allowed at idx $i in string \"$str\"")
            elseif str[i + 1] == '}'
                i = nextind(str, i + 1)
                continue
            else
                error("single '}' is not allowed at idx $i in string \"$str\"")
            end
        end

        if str[i] == '{'
            if i == lastindex(str)
                error("single '{' is not allowed at idx $i in string \"$str\"")
            elseif str[i + 1] == '{'
                i = nextind(str, i + 1)
                continue
            else
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

    found = i <= lastindex(str) && str[i] == '{'

    if count != 0 && found
        error("braces missmatch: \"$(str[i:end])\" at idx $i")
    end
    (
        j + 1,
        replace(replace(str[start:(i - 1)], "{{" => "{"), "}}" => "}"),
        found ? str[i + 1:j - 1] : nothing
    )
end


"""
`parse_fmt_spec(fmt_spec::String, arg)`

parse the format specifier. This can be done at compile time in @f_str
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
function combine(inbetweens, replacement_fields)
    result = ""
    for (i,(fmt_spec, arg)) in enumerate(replacement_fields)
        result *= inbetweens[i] * fmt(fmt_spec, arg)
    end
    result * inbetweens[end]
end