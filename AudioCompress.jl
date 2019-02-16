module AudioCompress
    struct state_s16
        x :: Int16
    end

    function init_s16(x::Int16)
        return state_s16(x)
    end

    function predict_s16(s::state_s16)
        return s.x
    end

    function update_s16(s::state_s16, x::Int16)
        return state_s16(x)
    end

    function encode_s16(raw)
        len, num_ch = size(raw)
        y = Array{Int32}(undef, len, num_ch)

        for ch=1:num_ch
            y[1,ch] = raw[1,ch]
            s = init_s16(raw[1,ch])

            for i=2:len
                x̂ = predict_s16(s)
                y[i,ch] = raw[i,ch] - x̂

                s = update_s16(s, raw[i,ch])
            end
        end

        return y
    end

    function decode_s16(y)
        len, num_ch = size(y)
        raw = Array{Int16}(undef, len, num_ch)

        for ch=1:num_ch
            raw[1,ch] = y[1,ch]
            s = init_s16(Int16(y[1,ch]))

            for i=2:len
                x̂ = predict_s16(s)
                raw[i,ch] = y[i,ch] + x̂

                s = update_s16(s, raw[i,ch])
            end
        end

        return raw
    end

end