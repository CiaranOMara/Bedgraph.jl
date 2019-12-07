"Check whether string is in the four column BED format."
function isLikeRecord(line::AbstractString)
    return occursin(r"^\s*\S*(?=[A-Za-z0-9])\S*\s+(\d+)\s+(\d+)\s+(\S*\d)\s*$", line) # Note: is like a record.
end
isLikeRecord(io::IO) = isLikeRecord(String(take!(io)))

"Check whether string has broswer information."
function isBrowser(line::AbstractString)
    return occursin(r"^browser", lowercase(line))
end

"Check whether string is a comment."
function isComment(line::AbstractString)
    return occursin(r"^\s*(?:#|$)", line)
end

function seekNextRecord(io::IO)

    pos = position(io)

    while !eof(io)
        pos = position(io)
        line = readline(io)

        if isLikeRecord(line)
            break
        end

    end

    return seek(io, pos)
end

"Seek position of next [`Record`](@ref)."
function Base.seek(io::IO, ::Type{Record})
    return seekNextRecord(io)
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

"Read string into type's constructor."
function Base.read(io::IO, obj::Type{Record})
    line = readline(io)
    return obj(line)
end

function readRecords(io::IO, sink)
    seekstart(io)

    while !eof(seek(io, Record))
        record = read(io, Record)
        push!(sink, record) #Note: converts Record to sink's eltype.
    end

    return sink

end

readRecords(io::IO, sink::Type) = readRecords(io::IO, sink())
readRecords(io::IO) = readRecords(io::IO, Vector{Record})

function Base.read(io::IO, ::Type{T}) where {T<:AbstractVector{Record}}
    return readRecords(io, T)
end
