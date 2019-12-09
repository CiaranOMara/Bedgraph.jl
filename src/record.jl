export Record

struct Record
    chrom::String
    first::Int
    last::Int
    value::Real
end

function Base.:(==)(a::Record, b::Record)
    return a.chrom  == b.chrom &&
           a.first == b.first &&
           a.last == b.last &&
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

function Record(data::AbstractVector{<:AbstractString})
    return convert(Record, data)
end

function Base.convert(::Type{Record}, data::AbstractVector{<:AbstractString})
    chrom, first, last, value = _convertCells(data)
    return Record(chrom, first, last, value)
end

function Base.convert(::Type{Vector{String}}, record::Record)
    return String[record.chrom, string(record.first), string(record.last), string(record.value)]
end

function Record(data::AbstractString)
    return convert(Record, data)
end

function Base.convert(::Type{Record}, str::AbstractString)
    data = _splitLine(str)
    return convert(Record, data)
end

function chrom(record::Record)
    return record.chrom
end

function Base.first(record::Record)
    return record.first
end

function Base.last(record::Record)
    return record.last
end

function value(record::Record)
    return record.value
end

## Internal helper functions.
function _splitLine(line::AbstractString)
    return filter(!isempty, split(line, r"\s"))[1:4]
end

function _convertCells(cells::AbstractVector{<:AbstractString})
    return cells[1], parse(Int, cells[2]), parse(Int, cells[3]), parse(Float64, cells[4]) #TODO: parse cell 4 as a generic Real.
end
