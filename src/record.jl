"The bedGraph record."
struct Record{T<:Real}
    chrom::String
    first::Int
    last::Int
    value::T

    Record{T}(chrom::String, first::Int, last::Int, value::T) where {T} = new{T}(chrom, first, last, value)
    Record{T}(chrom, first, last, value) where {T} = new{T}(_string(chrom), _int(first), _int(last), _real(value))
end

function Record(chrom, first, last, value)
    v = _real(value)
    return Record{typeof(v)}(chrom, first, last, v)
end

function Record(data) :: Record
    return data
end

function Record{T}(data) :: Record{T} where T
    return data
end

function Base.convert(::Type{Record}, str::AbstractString)
    data = _split_line(str)
    return Record(data[1], data[2], data[3], data[4])
end

function Base.convert(::Type{Record{T}}, str::AbstractString) where T
    data = _split_line(str)
    return Record{T}(data[1], data[2], data[3], data[4])
end

function Base.convert(::Type{Vector{String}}, record::Record)
    return String[record.chrom, string(record.first), string(record.last), string(record.value)]
end

function Base.convert(::Type{String}, record::Record, delim::String = " ")

    strs = [
        record.chrom,
        string(record.first),
        string(record.last),
        string(record.value)
    ]

    return join(strs, delim)
end

"Access [`Record`](@ref)'s chrom field."
function chrom(record::Record)
    return record.chrom
end

"Access [`Record`](@ref)'s left position."
function Base.first(record::Record)
    return record.first
end

"Access [`Record`](@ref)'s last position."
function Base.last(record::Record)
    return record.last
end

"Access [`Record`](@ref)'s value."
function value(record::Record)
    return record.value
end

function Base.:(==)(a::Record, b::Record)
    return a.chrom == b.chrom &&
           a.first == b.first &&
           a.last  == b.last &&
           a.value == b.value
end

function Base.isless(a::Record, b::Record, chrom_isless::Function=isless)

    if chrom_isless(a.chrom, b.chrom)
        return true
    end

    if a.first < b.first
        return true
    end

    if a.last < b.last
        return true
    end

    if a.value < b.value
        return true
    end

    return false
end

## Internal helper functions.
function _split_line(line::AbstractString)
    return split(line, r"\s", limit=5, keepempty=false) #Note: may return 5 elements.
end

function _int(pos)
    return pos
end

function _string(str)
    return str
end

function _real(x)
    return x
end

function _int(str::AbstractString)
    return parse(Float64, str) #Note: conversion to Int is completed when the Record is constructed.
end

function _real(str::AbstractString)
    return parse(Float64, str)
end
