macro f_str(str)
    inbetweens = String[]
    arguments  = String[]
    fmt_specs = String[]
    fmt_spec = ""
    nextidx = 1
    while fmt_spec !== nothing
        nextidx, inbetween, fmt_spec = JuFormatting.iterate_brackets_pair(str, nextidx)

        push!(inbetweens, inbetween)
        if fmt_spec !== nothing
            temp = split(fmt_spec, ":")
            if temp[1] == ""
                error("f_str: empty expression not allowed")
            end
            push!(arguments, temp[1])
            if length(temp) > 1
                push!(fmt_specs, temp[2])
            else
                push!(fmt_specs, "")
            end
        end
    end

    parsed_args = esc.(Meta.parse.(arguments))

    :(fstr_combine($inbetweens, $fmt_specs, $(parsed_args...)))
end

function fstr_combine(inbetweens, fmt_specs, arguments...)
    parsed_fmt_specs = tuple((parse_fmt_spec(fmt_specs[i], arg) for (i, arg) in enumerate(arguments))...)
    combine(inbetweens, parsed_fmt_specs, arguments)
end
