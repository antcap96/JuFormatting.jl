#TODO: error on empty argument

macro f_str(str)
    inbetweens = String[]
    arguments  = String[]
    formatstrs = String[]
    formatstr = ""
    nextidx = 1
    while formatstr !== nothing
        nextidx, inbetween, formatstr = JuFormatting.iterate_braces_pair(str, nextidx)

        push!(inbetweens, inbetween)
        if formatstr !== nothing
            temp = split(formatstr, ":")
            if temp[1] == ""
                error("f_str: empty expression not allowed")
            end
            push!(arguments, temp[1])
            if length(temp) > 1
                push!(formatstrs, temp[2])
            else
                push!(formatstrs, "")
            end
        end
    end

    parsed_args = Meta.parse.(arguments)

    :(fstr_combine($inbetweens, $formatstrs, $(parsed_args...)))
end

function fstr_combine(inbetweens, fmtstrs, arguments...)
    result = ""
    for i in 1:length(fmtstrs)
        result *= inbetweens[i] * fmt(fmtstrs[i], arguments[i])
    end
    result * inbetweens[end]
end