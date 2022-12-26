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

guardian_nov = read_folder("scraper/guardian/nov")
guardian_dec = read_folder("scraper/guardian/dec")

pundit_nov = read_folder("scraper/pundit/11")
pundit_dec = read_folder("scraper/pundit/12")

guardian_overall = (concat_files("scraper/guardian/nov") * "\n" * concat_files("scraper/guardian/dec")) |> count_frequencies
pundit_overall = (concat_files("scraper/pundit/11") * "\n" * concat_files("scraper/pundit/12")) |> count_frequencies

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

files = [
	"pundit_nov.png" => pundit_nov - guardian_nov
	"guardian_nov.png" => guardian_nov - pundit_nov

	"pundit_dec.png" => pundit_dec - guardian_dec
	"guardian_dec.png" => guardian_dec - pundit_dec

	"pundit_overall.png" => pundit_overall - guardian_overall
	"guardian_overall.png" => guardian_overall - pundit_overall
]

for (name, set) in files[6:6]
	paint(create_wordcloud(set), "results/pngs/$name", ratio=2)
end

map(files) do (name, set)
	frequencies = collect(set)
	frequencies = sort(frequencies; lt=(a, b) -> a[2] > b[2])
	frequencies = filter(x -> x[2] > 0, frequencies)[1:20]
	frequencies
end[6]