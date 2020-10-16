using JuFormatting
using PyCall
using Test

function test(str, args)
    println("julia>  format(\"$str\", $args...): \"", format(str, args...), "\"")
    println("python> \"$str\".format(*$args)   : \"", PyObject(str).format(args...), "\"")
    println()
    return format(str, args...) == PyObject(str).format(args...)
end

@testset "JuFormatting.jl" begin
    # Write your tests here.
    @test test("{:3} {:.5g}", Any[1, .34])
    @test test("{:.3G} {:F} {:4.1E} {:.100g} {:5f} {:6.3e} {}", rand(7))
    # fails because julia formats Inf and NaN different from python
    # @test test("{:f} {:g} {:e} {} {:f} {:g} {:e} {}", [Inf, Inf, Inf, Inf, NaN, NaN, NaN, NaN])
    @test test("{:F} {:G} {:E} {:F} {:G} {:E}", [Inf, -Inf, Inf, NaN, -NaN, NaN])
    @test test("{:#X} {:#x} {:#o} {:#b}", rand(1:100, 4))


end
