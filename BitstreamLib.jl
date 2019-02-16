module BitstreamLib

    # bit_length = 64*(i-1) + j
    mutable struct Bitstream
        xs  :: Vector{UInt64}
        i   :: Int
        j   :: Int
    end

    function Bitstream()
        return Bitstream([0],1,0)
    end

    function append!(s::Bitstream, bit::Bool)
        if s.j + 1 <= 64
            s.xs[s.i] |= (UInt64(bit)<<63) >> s.j
            s.j += 1
        else
            if s.i == length(s.xs)
                resize!(s.xs, 2*s.i)
            end

            s.xs[s.i+1] = UInt64(bit) << 63

            s.j = 1
            s.i += 1
        end

        return s
    end

    function append!(s::Bitstream, x::UInt64, j::Int)
        if s.j + j <= 64
            s.xs[s.i] |= x >> s.j
            s.j += j
        else
            if s.i+1 > length(s.xs)
                resize!(s.xs, 2*s.i)
            end

            s.xs[s.i]  |= x >> s.j
            s.xs[s.i+1] = x << (64-s.j)

            s.j += j
            s.j -= 64
            s.i += 1
        end

        return s
    end

    function append!(s1::Bitstream, s2::Bitstream)
        for i=1:s2.i-1
            if s1.i+1 > length(s1.xs)
                resize!(s1.xs, 2*s1.i)
            end

            s1.xs[s1.i]  |= s2.xs[i] >> s1.j
            s1.xs[s1.i+1] = s2.xs[i] << (64-s1.j)

            s1.i += 1
        end

        if s1.j + s2.j < 64
            s1.xs[s1.i] |= s2.xs[s2.i] >> s1.j
            s1.j += s2.j
        else
            if s1.i+1 > length(s1.xs)
                resize!(s1.xs, 2*s1.i)
            end

            s1.xs[s1.i]  |= s2.xs[s2.i] >> s1.j
            s1.xs[s1.i+1] = s2.xs[s2.i] << (64-s1.j)

            s1.j += s2.j
            s1.j -= 64
            s1.i += 1
        end

        return s1
    end
end