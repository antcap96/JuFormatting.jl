macro f_str(str)
    inbetweens, arguments, fmt_specs = parse_original_string(str)

    parsed_args = esc.(Meta.parse.(arguments))

    :(fstr_combine($inbetweens, $fmt_specs, $(parsed_args...)))
end

function fstr_combine(inbetweens, fmt_specs, arguments...)
    parsed_fmt_specs = tuple((parse_fmt_spec(fmt_specs[i], arg) for (i, arg) in enumerate(arguments))...)
    combine(inbetweens, parsed_fmt_specs, arguments)
end
