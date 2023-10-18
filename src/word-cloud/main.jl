include("generator.jl")

using WordCloud

function concat_files(path)
	big = map(readdir(path)) do file
		String(read("$path/$file"))
	end

	big = join(big, " ")
end

function read_folder(path)
	big = concat_files(path)
	count_frequencies(big)
end

guardian_nov = read_folder("./output/scrapper/guardian/november")
guardian_dec = read_folder("./output/scrapper/guardian/december")

pundit_nov = read_folder("./output/scrapper/pundit/november")
pundit_dec = read_folder("./output/scrapper/pundit/december")

guardian_overall = (concat_files("./output/scrapper/guardian/november") * "\n" * concat_files("./output/scrapper/guardian/december")) |> count_frequencies
pundit_overall = (concat_files("./output/scrapper/pundit/november") * "\n" * concat_files("./output/scrapper/pundit/december")) |> count_frequencies

# patient is the whole set and surgeon is the one that removes the words
function Base.:(-)(patient, surgeon)
	patient = deepcopy(patient)

	session = sum(values(patient)) / sum(values(surgeon))

	for word ∈ keys(patient)
		if word ∈ keys(surgeon)
			patient[word] -= round(Int, surgeon[word] * session)
		end
	end

	patient
end

files(extension::AbstractString="svg") = [
	"pundit_nov.$extension" => pundit_nov - guardian_nov
	"guardian_nov.$extension" => guardian_nov - pundit_nov

	"pundit_dec.$extension" => pundit_dec - guardian_dec
	"guardian_dec.$extension" => guardian_dec - pundit_dec

	"pundit_overall.$extension" => pundit_overall - guardian_overall
	"guardian_overall.$extension" => guardian_overall - pundit_overall
]

for (name, set) in files()
	name = "output/wordclouds/$name"

	paint(create_wordcloud(set), name)

	println("Saved $name")
end
