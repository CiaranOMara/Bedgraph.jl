function _bump(records::AbstractVector{R}, b::Int) where {T, R<:Record{T}}

    new_records = Vector{R}(undef, length(records))

    for (i, record) in enumerate(records)
        new_record  = Record{T}(record.chrom, record.first + b, record.last + b, record.value)
        new_records[i] = new_record
    end

    return new_records
end

_bump_forward(records::AbstractVector{<:Record}) = _bump(records, 1)
_bump_back(records::AbstractVector{<:Record}) = _bump(records, -1)


function _range(record::Record; right_open=true)

    pos_start = right_open ? record.first : record.first + 1
    pos_end = right_open ? record.last - 1 : record.last

    return pos_start : pos_end
end


function _range(records::AbstractVector{<:Record}; right_open=true)

    pos_start = _range(records[1], right_open=right_open)[1]
    pos_end = _range(records[end], right_open=right_open)[end]

    return  pos_start : pos_end
end
