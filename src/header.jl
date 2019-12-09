"A container for the bedGraph header."
mutable struct BedgraphHeader{T} #TODO: determine what and how this will be.
    data::T
end
BedgraphHeader{T}() where T = BedgraphHeader{T}(T())
BedgraphHeader() = BedgraphHeader{Vector{String}}()

"Push data into [`BedgraphHeader`](@ref) container."
function Base.push!(sink::BedgraphHeader, data)
    push!(sink.data, data) #Note: converts data to sink.data's eltype.
end

"Convert [`BedgraphHeader`](@ref) to type `String`."
function Base.convert(::Type{String}, header::BedgraphHeader{<:AbstractVector{<:AbstractString}})

    str = ""
    for line in header.data
        str = string(str, line, '\n')
    end

    return str
end

"Generate a basic bedGraph header given a vector of [`Record`](@ref)s."
function generateBasicHeader(records::AbstractVector{Record}; bump_forward=true) #Note: we assume that records are sorted by chrom and left position.

    chrom = records[1].chrom

    pos_start = records[1].first
    pos_end = records[end].last

    if bump_forward
        pos_start = pos_start + 1
        pos_end = pos_end + 1
    end

    return BedgraphHeader(["browser position $chrom:$pos_start-$pos_end", "track type=bedGraph"])
end

generateBasicHeader(chrom::AbstractString, pos_start::Int, pos_end::Int; bump_forward=true) = generateBasicHeader([Record(chrom, pos_start, pos_end, 0)], bump_forward=bump_forward)

"Seek and then read bedGraph header into sink."
function _readHeader(io::IO, sink)
    position(io) == 0 || seekstart(io)

    line = readline(io)

    while !eof(io) && !isLikeRecord(line) # TODO: seek more rebust check.
        push!(sink, line)
        line = readline(io)
    end

    return sink
end

"Read bedGraph header into sink."
function Base.read(io::IO, sink::Type{<:BedgraphHeader})
    return _readHeader(io, sink())
end

"Write bedGraph header to `IO` as `String`."
function Base.write(io::IO, header::BedgraphHeader)
    return Base.write(io, convert(String, header))
end
