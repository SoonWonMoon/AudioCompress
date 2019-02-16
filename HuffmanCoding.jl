include("BitstreamLib.jl")

module HuffmanCoding
    using DataStructures

    abstract type Node end

    # f     : Frequency
    # node0 : Left node
    # node1 : Right node
    # a     : Alphabet

    struct Branch <: Node
        f :: UInt
        node0 :: Node
        node1 :: Node
    end

    struct Leaf{T} <: Node
        f :: UInt
        a :: T
    end

    function generateFrequencyDict(data::Vector)
        dict = Dict{eltype(data), UInt}()

        for a in data
            if haskey(dict, a)
                dict[a] += 1
            else
                dict[a] = 1
            end
        end

        return dict
    end

    function generateHuffmanTree(dict::Dict)
        leafs = [Leaf(pair[2], pair[1]) for pair in dict]
        sort!(leafs, lt = (x,y) -> x.f<y.f)

        n = length(leafs)

        q1 = Queue{Node}()
        for leaf in leafs
            enqueue!(q1, leaf)
        end

        q2 = Queue{Node}()

        for i=1:n-1
            if isempty(q1)
                node0 = dequeue!(q2)
                node1 = dequeue!(q2)
            elseif isempty(q2)
                node0 = dequeue!(q1)
                node1 = dequeue!(q1)
            else
                if front(q1).f < front(q2).f
                    node0 = dequeue!(q1)

                    if isempty(q1)
                        node1 = dequeue!(q2)
                    else
                        node1 = front(q1).f < front(q2).f ? dequeue!(q1) : dequeue!(q2)
                    end
                else
                    node0 = dequeue!(q2)

                    if isempty(q2)
                        node1 = dequeue!(q1)
                    else
                        node1 = front(q1).f < front(q2).f ? dequeue!(q1) : dequeue!(q2)
                    end
                end
            end

            enqueue!(q2, Branch(node0.f + node1.f, node0, node1))
        end

        return front(q2)
    end

    function generateCodeDict(tree::Node)
        function iterate(tree::Node, prefix::Main.BitstreamLib.Bitstream)
            if typeof(tree) <: Leaf
                return Dict(tree.a => prefix)
            else
                prefix0 = prefix
                prefix1 = deepcopy(prefix0)
                Main.BitstreamLib.append!(prefix0, false)
                Main.BitstreamLib.append!(prefix1, true)

                dict0 = iterate(tree.node0, prefix0)
                dict1 = iterate(tree.node1, prefix1)

                return merge(dict0, dict1)
            end
        end

        return iterate(tree, Main.BitstreamLib.Bitstream())
    end

    function encode(data::Vector, dict::Dict)
        encoded = Main.BitstreamLib.Bitstream()

        for a in data
            Main.BitstreamLib.append!(encoded, dict[a])
        end

        return encoded
    end

    # the performance of decode() function is very bad
    # It will be changed in updates
    function decode(data::Main.BitstreamLib.Bitstream, tree::Node)
        decoded = Vector()

        i = 1
        j = 1

        while (i < data.i) || (i == data.i && j <= data.j)
            node = tree

            while typeof(node) == Branch
                if (data.xs[i] >> (64-j)) & UInt64(1) == 0
                    node = node.node0
                else
                    node = node.node1
                end

                j += 1
                if j > 64
                    i += 1
                    j = 1
                end
            end

            push!(decoded, node.a)
        end

        return decoded
    end

    # abstract type Cell end

    # struct Empty <: Cell end

    # struct Match{T} <: Cell
    #     a :: T
    #     bitLength :: Int
    # end

    # struct Table <: Cell
    #     table :: Vector{Cell}
    # end

    # function Table()
    #     return Table(Vector{Cell}(fill(Empty(), 2^8)))
    # end

    # function decode(data::Main.BitstreamLib.Bitstream, dict::Dict)
    #     function addMatch(table::Table, a, code, i, j, leftBitLength)
    #         # left_length = 64*(code.i-i) + (code.j - j)
    #         if leftBitLength > 8
    #             if j + 8 > 64
    #                 _code  = (code.xs[i]   >> (64  - j - 8)) & 0xff
    #                 _code |= (code.xs[i+1] >> (128 - j - 8))
    #             else
    #                 _code  = (code.xs[i]   >> (64  - j - 8)) & 0xff
    #             end

    #             if table.table[_code] == Empty()
    #                 table.table[_code] = Table()
    #             end
    #             j += 8
    #             addMatch(table.table[_code], a, code, i,)
    #             table.table[_code] = Match(a, 64*(code.i-1) + code.j)

    #             leftBitLength -= 8
    #         else
                
    #         end
    #     end

    #     table = Table()

    #     for pair in dict
    #         a = pair[1]
    #         code = pair[2]
            
    #     end

    # end
end