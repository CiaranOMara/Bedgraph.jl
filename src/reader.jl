# Check if the record data is in the four column BED format.
function isLikeRecord(line::AbstractString)
    return occursin(r"^\s*\S*(?=[A-Za-z0-9])\S*\s+(\d+)\s+(\d+)\s+(\S*\d)\s*$", line) # Note: is like a record.
end
isLikeRecord(io::IO) = isLikeRecord(String(take!(io)))

function isBrowser(line::AbstractString)
    return  occursin(r"^browser", lowercase(line))
end

function isComment(line::AbstractString)
    return occursin(r"^\s*(?:#|$)", line)
end


function seekNextRecord(io::IO)

    pos = position(io)
    initial = pos == 0 ? -1 : pos # Note: Allows for the fist line of headerless bedGraph file to be read.
    line = ""

    while !eof(io) && (!isLikeRecord(line) || pos == initial)
        pos = position(io)
        line = readline(io)
    end

    seek(io, pos)

    return nothing

end

# Note: all options are placed in a single line separated by spaces.
function readParameters(io::IO)
    seekstart(io)

    pos = position(io)

    while !eof(io) && !isLikeRecord(line) # Note: regex is used to limit the search by exiting the loop when a line matches the bedGraph record format.
        line = readline(io)

        if contains(line, "type=bedGraph") # Note: the track type is REQUIRED, and must be bedGraph.
            return line
        end

    end
end

function readRecord(io::IO) :: Union{Nothing, Record}

    line = IOBuffer(readline(io))

    if isLikeRecord(line)
        return read(line, Record)
    end

    return nothing
end

function Base.read(io::IO, obj::Type{Record})
    line = readline(io)
    return obj(line)
end

function readRecords(io::IO, sink)
    seekstart(io)
    seekNextRecord(io)

    while !eof(io)
        record = readRecord(io)
        if record != nothing
            push!(sink, record) #Note: converts Record to sink's eltype.
        end
    end

    return sink

end

readRecords(io::IO, sink::Type) = readRecords(io::IO, sink())
readRecords(io::IO) = readRecords(io::IO, Vector{Record})

function Base.read(io::IO, ::Type{T}) where {T<:AbstractVector{Record}}
    return readRecords(io, T)
end
