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

guardian_nov = read_folder("scrapper/guardian/nov")
guardian_dec = read_folder("scrapper/guardian/dec")

pundit_nov = read_folder("scrapper/pundit/11")
pundit_dec = read_folder("scrapper/pundit/12")

guardian_overall = (concat_files("scrapper/guardian/nov") * "\n" * concat_files("scrapper/guardian/dec")) |> count_frequencies
pundit_overall = (concat_files("scrapper/pundit/11") * "\n" * concat_files("scrapper/pundit/12")) |> count_frequencies

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
	"pundit_nov.png" => create_wordcloud(pundit_nov - guardian_nov; max_words=700)
	"guardian_nov.png" => create_wordcloud(guardian_nov - pundit_nov; max_words=700)

	"pundit_dec.png" => create_wordcloud(pundit_dec - guardian_dec; max_words=700)
	"guardian_dec.png" => create_wordcloud(guardian_dec - pundit_dec; max_words=700)

	"pundit_overall.png" => create_wordcloud(pundit_overall - guardian_overall; max_words=700)
	"guardian_overall.png" => create_wordcloud(guardian_overall - pundit_overall; max_words=700)
]

for (name, wc) in files
	paint(wc, "results/pngs/$name", ratio=2)
end

let
	frequencies = guardian_overall - pundit_overall
	frequencies = collect(frequencies)
	frequencies = sort(frequencies; lt=(a, b) -> a[2] > b[2])
	frequencies = filter(x -> x[2] > 0, frequencies)[1:20]
end