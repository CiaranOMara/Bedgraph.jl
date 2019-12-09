__precompile__()

module Bedgraph

include("record.jl")
include("helpers.jl")
include("header.jl")
include("reader.jl")
include("writer.jl")


import Base.convert
@deprecate convert(::Type{Vector{Record}}, chroms::AbstractVector{<:AbstractString}, firsts::AbstractVector{Int}, lasts::AbstractVector{Int}, values::AbstractVector{<:Real}) Record.(chroms, firsts, lasts, values)

end # module
