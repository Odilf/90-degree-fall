using WordCloud

# usesless_words = split(String(read("./bad_words.txt")), "\n")

const global_frequencies = map(split.(split(String(read("./unigram_freq.csv")), "\n"), ",")) do (word, frequency)
	word => parse(BigInt, frequency)
end |> Dict

usesless_words = let
	sorted = sort(collect(global_frequencies), lt=(a, b) -> a[2] > b[2])
	most_common = map(w -> w[1], sorted)[1:20]

	bad_words = split(String(read("bad_words.txt")), "\n")
	[most_common..., bad_words...]
end

function count_frequencies(article)::Dict{String, Float32}
	frequencies = Dict()

	words = filter(x -> length(x) > 0, split(article, " "))
	words = filter(word -> lowercase(word) ∉ usesless_words, words)

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
		# rt = 1,
		# centeredword = 1,
		density = 0.55,
		mask = shape(ellipse, 2400, 1600, color=(0.1, 0.05, 0.1, 1)),
		# maxfontsize = 200,
	)

	placewords!(wc, style=:gathering, level=5, centeredword=true, rt=1)

	generate!(wc)
end