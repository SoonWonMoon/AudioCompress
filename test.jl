import WAV

include("AudioCompress.jl")
include("HuffmanCoding.jl")

function stddev(A)
    m,n = size(A)

    μ_A = dropdims(sum(A, dims=1), dims=1) / m

    var = zeros(n)

    for j=1:n
        var[j] = sum((A[:,j] .- μ_A[j]).^2) / m
    end

    return sqrt.(var)
end

function main()
    filename = ARGS[1]
    raw, fs = WAV.wavread(filename, format="int16")

    @time data = raw |> AudioCompress.encode_s16 |> vec

    @time tree = data |> HuffmanCoding.generateFrequencyDict |> HuffmanCoding.generateHuffmanTree
    @time dict = tree |> HuffmanCoding.generateCodeDict
    @time encoded = HuffmanCoding.encode(data, dict)
    @time decoded = HuffmanCoding.decode(encoded, tree)

    print("Error is : ")
    println(sum(abs.(data-decoded)))

    print("Compress rate is : ")
    println( (encoded.i * 64) / (length(raw)*16) )
end

main()
