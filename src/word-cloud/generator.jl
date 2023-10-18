using WordCloud

const global_frequencies = begin
	path = joinpath(@__DIR__, "unigram_freq.csv")
	content = read(path, String) |> strip
	splits = split.(split(content, "\n"), ",")
	
	map(splits) do (word, frequency)
		word => parse(BigInt, frequency)
	end |> Dict
end

useless_words = let
	sorted = sort(collect(global_frequencies), lt=(a, b) -> a[2] > b[2])
	most_common = map(w -> w[1], sorted)[1:20]

	unimportant_words = split(read(joinpath(@__DIR__, "unimportant_words.txt"), String), "\n")
	[most_common..., unimportant_words...]
end

function count_frequencies(article)::Dict{String, Float32}
	frequencies = Dict()

	words = strip.(split(article, " "))
	
	words = filter(x -> length(x) > 0, words)
	words = filter(word -> lowercase(word) ∉ useless_words, words)
	words = filter(word -> tryparse(Float64, word) === nothing, words)

	for word ∈ words
		if  word ∉ keys(frequencies)
			frequencies[word] = 1
		else
			frequencies[word] += 1
		end
	end

	frequencies
end

function create_wordcloud(frequencies; max_words = 400)
	frequencies = collect(frequencies)
	frequencies = sort(frequencies; lt=(a, b) -> a[2] > b[2])
	frequencies = filter(x -> x[2] > 0, frequencies)

	words::Vector{String} = [f[1] for f ∈ frequencies][1:max_words]
	weights::Vector{Int} = [f[2] for f ∈ frequencies][1:max_words]

	wc = wordcloud(
		words, weights;
		colors = :Pastel1_7,
		angles = -0:0,
		fonts = "Helvetica Neue Extrabold",
		density = 0.65,
		mask = shape(ellipse, 2400, 1600, color=(0.1, 0.05, 0.1, 1)),
		maxfontsize = 300,
	)

	layout!(wc, style=:gathering, rt=1, centralword=true)

	generate!(wc, reposition=0.7)
end
