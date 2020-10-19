module JuFormatting

using Base.Ryu

# Write your package code here.

export
    format,
    @f_str

include("main.jl")
include("numberformatparser.jl")
include("floatingpointformating.jl")
include("integerformating.jl")
include("fmacro.jl")

end
