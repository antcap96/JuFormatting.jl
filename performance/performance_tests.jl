using Pkg

Pkg.activate(joinpath(dirname(@__FILE__), ".."))

using JuFormatting
using BenchmarkTools
using Random
using JLD

# Define a parent BenchmarkGroup to contain our suite
suite = BenchmarkGroup()

precision_fmt = Dict{String, String}()

for t in ["f", "g", "e", ""]
    precision_fmt[t] = string(["{:.$i$t}" for i in 1:100]...)
end

suite["fixed precision"] = BenchmarkGroup(["float", "number"])
suite["exp"] = BenchmarkGroup(["float", "number"])
suite["general"] = BenchmarkGroup(["float", "number"])
suite["default"] = BenchmarkGroup(["float", "number"])

suite["fixed precision"]["fmt"]       = @benchmarkable JuFormatting.fmt("f", $(rand()))
suite["fixed precision"]["one"]       = @benchmarkable format("{:f}", $(rand()))
suite["fixed precision"]["small"]     = @benchmarkable format("{:f} {:f}", $(rand()), $(rand()))
suite["fixed precision"]["long"]      = @benchmarkable format("{:f}"^100, $([rand() for i in 1:100])...)
suite["fixed precision"]["precision"] = @benchmarkable format(precision_fmt["f"], $([rand() for i in 1:100])...)

suite["exp"]["fmt"]       = @benchmarkable JuFormatting.fmt("e", $(rand()))
suite["exp"]["one"]       = @benchmarkable format("{:e}", $(rand()))
suite["exp"]["small"]     = @benchmarkable format("{:e} {:e}", $(rand()), $(rand()))
suite["exp"]["long"]      = @benchmarkable format("{:e}"^100, $([rand() for i in 1:100])...)
suite["exp"]["precision"] = @benchmarkable format(precision_fmt["e"], $([rand() for i in 1:100])...)

suite["general"]["fmt"]       = @benchmarkable JuFormatting.fmt("g", $(rand()))
suite["general"]["one"]       = @benchmarkable format("{:g}", $(rand()))
suite["general"]["small"]     = @benchmarkable format("{:g} {:g}", $(rand()), $(rand()))
suite["general"]["long"]      = @benchmarkable format("{:g}"^100, $([rand() for i in 1:100])...)
suite["general"]["precision"] = @benchmarkable format(precision_fmt["g"], $([rand() for i in 1:100])...)

suite["default"]["fmt"]       = @benchmarkable JuFormatting.fmt("", $(rand()))
suite["default"]["one"]       = @benchmarkable format("{:}", $(rand()))
suite["default"]["small"]     = @benchmarkable format("{:} {:}", $(rand()), $(rand()))
suite["default"]["long"]      = @benchmarkable format("{:}"^100, $([rand() for i in 1:100])...)
suite["default"]["precision"] = @benchmarkable format(precision_fmt[""], $([rand() for i in 1:100])...)

# If a cache of tuned parameters already exists, use it, otherwise, tune and cache
# the benchmark parameters. Reusing cached parameters is faster and more reliable
# than re-tuning `suite` every time the file is included.
paramspath = joinpath(dirname(@__FILE__), "params_nokwards.json")

if isfile(paramspath)
    loadparams!(suite, BenchmarkTools.load(paramspath)[1], :evals);
else
    tune!(suite)
    BenchmarkTools.save(paramspath, params(suite));
end

results = run(suite, verbose = true)

save(joinpath(dirname(@__FILE__), "result_nokwards.jld"), "results_nokwards", results)
println(results)