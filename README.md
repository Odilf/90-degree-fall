# 90-degree-fall

An analysis of word usage on left ([The Guardian](https://www.theguardian.com/us-news)) and right ([The Gateway Pundit](https://www.thegatewaypundit.com/)) news outlets. 

## Explanation

We took the first article of each day of November and December of the two websites and tallied the frequencies of each word. The choice of newspapers was largely because these two were easier to scrape, since they have dates in their url (maybe I could've used RSS but I couldn't be bothered to learn how it works lol). For each day, the scraper finds the first article link and subsequently copies all of the text of the article. 

At first, we wanted to create a word cloud with the frequency of each word. However, the results are very dissapointing, since the most used words are the most common English words. That's not very insightful. Therefore, we need to find a way to compensate for the natural frequency of words.

There is a [dataset of frequency of English words](https://www.kaggle.com/datasets/rtatman/english-word-frequency), but it didn't turn out to be that useful. In the end, the most sucessful idea was subtracting one dataset from the other. This is to leverage the fact that we are doing a comparison. For example, to create the word cloud for The Guardian we would go through each word and subtract the frequency of that word in TGP (if it appears). This way we get the most common words in The Guardian *that TGP doesn't use* (we do the same for TGP).

Some manual filtering is still needed though: 
 - The scraper got advertisments from TGP so we removed those by hand
 - We filtered the 20 most common English words
 - We removed single letters
 - The spaces in "Mar a Lago" were replaced by non-breaking spaces to consider it a single word
 - We removed numbers
 - We removed some other common irrelevant words (the specific word filter can be seen in `unimportant_words.txt`)

## Results

Wordclouds of November and December 2022 for:

The Guardian:
![Wordcloud guardian](output/wordclouds/guardian_overall.svg)

The Gateway Pundit:
![Wordcloud pundit](output/wordclouds/pundit_overall.svg)

## Usage

This project uses npm and [Julia](https://julialang.org/), make sure to have installed both.

First, install npm dependencies

```bash
npm i # Or pnpm i
```

To scrape the websites you can run the `scrape` command from npm which will guide you with an interactive session on the command line

```bash
➜ pnpm scrape

> 90-degree-fall@1.0.0 scrape /Users/odilf/Documents/Code/90-degree-fall
> tsc && node ./dist/main.js

┌  Welcome to 90-degree-fall
│
◇  Pick the outlet to scrape
│  The Guardian, The Gateway Pundit
│
◆  Pick months
│  ◼ November
│  ◻ December
└
```

To generate the word clouds, you can run `npm word-cloud`. You can also just use it through a regular interactive session with Julia

## Epilogue

yes. it did hurt
