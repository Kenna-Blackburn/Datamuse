
# Datamuse

A Swift Package for the [Datamuse API](https://www.datamuse.com/api/).

| In order to find... | ...use `let dm = Datamuse(); // ...` |
| --- | --- |
| words with a meaning similar to ringing in the ears | `dm.words([.meaningLike("ringing in the ears")])` |
| words related to duck that start with the letter b | `dm.words([.meaningLike("duck"), .spelledLike(#"b*"#)])` |
| words related to spoon that end with the letter a | `dm.words([.meaningLike("spoon"), .spelledLike(#"*a"#)])` |
| words that sound like jirraf | `dm.words([.soundsLike("jirraf")` |
| words that start with t, end in k, and have two letters in between | `dm.words([.spelledLike(#"t??k"#)])` |
| words that are spelled similarly to hipopatamus | `dm.words([.spelledLike("hipopatamus")])` |
| adjectives that are often used to describe ocean | `dm.words([.describing("ocean")])` |
| adjectives describing ocean sorted by how related they are to temperature | `dm.words([.describing("ocean"), .topicWords(["temperature"])])` |
| nouns that are often described by the adjective yellow | `dm.words([.described(by: "yellow")])` |
| words that often follow "drink" in a sentence, that start with the letter w | `dm.word([.leftContext("w"), .spelledLike(#"w*"#)])` |
| words that are triggered by (strongly associated with) the word "cow" | `dm.words([.triggered(by: "cow")])` |
| suggestions for the user if they have typed in rawand so far | `dm.suggestions("rawand")` |

> [!TIP]
> The DocC for `AnyParameter.spelledLike(_:)` has a cheat sheet for the Wildcard Pattern.
