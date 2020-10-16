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
    @test test("{:.3G} {:F} {:4.1E} {:.100g} {:5f} {:6.3e} {:%} {}", rand(8))
    # fails because julia formats Inf and NaN different from python
    # edge cases
    # @test test("{:f} {:g} {:e} {} {:f} {:g} {:e} {}", [Inf, Inf, Inf, Inf, NaN, NaN, NaN, NaN])
    @test test("{:F} {:G} {:E} {:F} {:G} {:E}", [Inf, -Inf, Inf, NaN, -NaN, NaN])
    @test test("{:f} {:g} {:e} {}", zeros(4))

    # integer representations
    @test test("{:#X} {:#x} {:#o} {:#b}", rand(1:100, 4))
    @test test("{:X} {:x} {:o} {:b}", rand(1:100, 4))

    # rounding
    @test test("{:.1f}", 0.99)
    @test test("{:.1g}", 0.99)
    @test test("{:.1e}", 0.99)
    @test test("{:.1}" , 0.99)

    # aling and fill and escape braces
    @test test("{:a<10x}", rand(1:500))
    @test test("{: ^10} }}{{", -rand(1:500))
    @test test("{: >+10} }}", rand(1:500))
    @test test("{: ^ 10} {{", rand(1:500))
    @test test("{:+015x}", rand(1:500))

end
