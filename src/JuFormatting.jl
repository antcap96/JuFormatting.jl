module JuFormatting

using Base.Ryu

# Write your package code here.

export
    format,
    @f_str

include("main.jl")
include("number_formatting/general.jl")
include("number_formatting/floatingpoint.jl")
include("number_formatting/integer.jl")
include("fmacro.jl")

end
