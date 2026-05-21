//
//  AnyParameter.swift
//  Datamuse
//
//  Created by Kenna Blackburn on 5/20/26.
//

import Foundation

public struct AnyParameter {
    public let modify: (inout URLRequest) -> Void
    public let supportsSuggestions: Bool
    
    public init(
        supportsSuggestions: Bool = false,
        _ modify: @escaping (_ req: inout URLRequest) -> Void,
    ) {
        self.modify = modify
        self.supportsSuggestions = supportsSuggestions
    }
    
    public init(_ parameters: [AnyParameter]) {
        self.init(supportsSuggestions: parameters.allSatisfy(\.supportsSuggestions)) { req in
            parameters.forEach({ $0.modify(&req) })
        }
    }
    
    public init(_ key: String, value: String, supportsSuggestions: Bool = false) {
        self.init(supportsSuggestions: supportsSuggestions) { req in
            req.url?.append(queryItems: [.init(name: key, value: value)])
        }
    }
    
    public init(path: String) {
        self.init(supportsSuggestions: true, { req in req.url?.append(path: path) })
    }
}

extension AnyParameter {
    /// Require that the results have a meaning related to this string value, which can be any word or sequence of words.
    ///
    /// This is effectively the [reverse dictionary](https://onelook.com/reverse-dictionary.shtml) feature of OneLook.
    public static func meansLike(_ string: String) -> Self {
        return .init("ml", value: string)
    }
    
    /// Require that the results are pronounced similarly to this string of characters.
    ///
    /// If the string of characters doesn't have a known pronunciation,
    /// the system will make its best guess using a text-to-phonemes algorithm.
    public static func soundsLike(_ string: String) -> Self {
        return .init("sl", value: string)
    }
    
    /// Require that the results are spelled similarly to this string of characters, or that they match the wildcard pattern.
    ///
    /// # Wildcard Pattern
    ///
    /// * The asterisk (`*`) matches any number of letters.
    /// That means that you can use it as a placeholder for any part of a word or phrase.
    /// For example, if you enter `blueb*` you'll get all the terms that start with "blueb";
    /// if you enter `*bird` you'll get all the terms that end with "bird";
    /// if you enter `*lueb*` you'll get all the terms that contain the sequence "lueb", and so forth.
    /// An asterisk can match zero letters, too.
    ///
    /// * The question mark (`?`) matches exactly one letter.
    /// That means that you can use it as a placeholder for a single letter or symbol.
    /// The query `l?b?n?n`,  for example, will find the word "Lebanon".
    ///
    /// * The number-sign (`#`) matches any English consonant.
    /// For example, the query `tra#t` finds the word "tract" but not "trait".
    ///
    /// * The at-sign (`@`) matches any English vowel (including "y").
    /// For example, the query `abo@t` finds the word "about" but not "abort".
    ///
    /// * The comma (`,`) lets you combine multiple patterns into one.
    /// For example, the query `?????,*y*` finds 5-letter words that contain a "y" somewhere, such as "happy" and "rhyme".
    ///
    /// * Use double-slashes (`//`) before a group of letters to unscramble them (that is, find anagrams).
    /// For example, the query `//soulbeat` will find "absolute" and "bales out",
    /// and `re//teeprsn` will find "represent" and "repenters".
    /// You can use another double-slash to end the group and put letters you're sure of to the right of it.
    /// For example, the query `//blabrcs//e` will find "scrabble".
    /// Question marks can signify unknown letters as usual;
    /// for example, `//we???` returns 5-letter words that contain a W and an E, such as "water" and "awake".
    ///
    /// * A minus sign (`-`) followed by some letters at the end of a pattern means "exclude these letters".
    /// For example, the query `sp???-ei` finds 5-letter words that start with "sp" but do not contain an "e"or an "i", such as "spoon" and "spray".
    ///
    /// * A plus sign (`+`) followed by some letters at the end of a pattern means "restrict to these letters".
    /// For example, the query `*+ban` finds "banana". 
    public static func spelledLike(_ string: String) -> Self {
        return .init("sp", value: string)
    }
    
    /// Require that the results are nouns modified by the given adjective.
    ///
    /// > Example: `gradual -> increase`
    public static func described(by adjective: String) -> Self {
        return .init("rel_jja", value: adjective)
    }
    
    /// Require that the results are adjectives modified by the given noun.
    ///
    /// > Example: `beach -> sandy`
    public static func describing(_ noun: String) -> Self {
        return .init("rel_jjb", value: noun)
    }
    
    /// Require that the results are synonyms with the given word.
    ///
    /// > Example: `ocean -> sea`
    public static func synonym(_ word: String) -> Self {
        return .init("rel_syn", value: word)
    }
    
    /// Require that the results are statistically associated with the given word in the same piece of text.
    ///
    /// > Example: `cow -> milking`
    public static func triggered(by word: String) -> Self {
        return .init("rel_trg", value: word)
    }
    
    /// Require that the results are antonyms (words contained within the same WordNet synset).
    ///
    /// > Example: `late -> early`
    public static func antonym(_ word: String) -> Self {
        return .init("rel_ant", value: word)
    }
    
    /// Require that the results are generalizations of the given word.
    ///
    /// > Example: `gondola -> boat`
    public static func generalization(of word: String) -> Self {
        return .init("rel_spc", value: word)
    }
    
    /// Require that the results are specifications of the given word.
    ///
    /// > Example: `boat -> gondola`
    public static func specification(of word: String) -> Self {
        return .init("rel_gen", value: word)
    }
    
    /// Require that the results are a part of the given part.
    ///
    /// > Example: `car -> accelerator`
    public static func subpart(of word: String) -> Self {
        return .init("rel_com", value: word)
    }
    
    /// Require that the given word is a part of the results.
    ///
    /// > Example: `trunk -> tree`
    public static func superpart(of word: String) -> Self {
        return .init("rel_par", value: word)
    }
    
    /// Require that the results frequently follow the given word.
    ///
    /// > Example: `wreak -> havoc`
    ///
    /// "Frequent followers" are defined as `w′` such that `P(w′|w) ≥ 0.001`, per Google Books Ngrams.
    public static func frequentFollower(to word: String) -> Self {
        return .init("rel_bga", value: word)
    }
    
    /// Require that the results frequently predece the given word.
    ///
    /// > Example: `havoc -> wreak`
    ///
    /// "Frequent predecessors" are defined as `w′` such that `P(w|w′) ≥ 0.001`, per Google Books Ngrams.
    public static func frequentPredecessor(to word: String) -> Self {
        return .init("rel_bgb", value: word)
    }
    
    /// Require that the results are homophones with the given word (sound alike).
    ///
    /// > Example: `course -> coarse`
    public static func homophone(_ word: String) -> Self {
        return .init("rel_hom", value: word)
    }
    
    /// Require that the results are consonant match with the given word.
    ///
    /// > Example: `sample -> simple`
    public static func consonantMatch(_ word: String) -> Self {
        return .init("rel_cns", value: word)
    }
    
    public struct Vocabulary: Sendable {
        public let id: String
        
        public init(_ id: String) {
            self.id = id
        }
        
        public static let spanish: Self = .init("es")
    }
    
    /// Set the vocabulary to use.
    ///
    /// If none is provided, a 550,000-term vocabulary of English words and multiword expressions is used.
    /// The value ``Vocabulary/spanish`` specifies a 500,000-term vocabulary of words from Spanish-language books.
    public static func vocabulary(_ vocabulary: Vocabulary) -> Self {
        return .init("v", value: vocabulary.id, supportsSuggestions: true)
    }
    
    /// Set a hint to the system about the theme of the document being written.
    ///
    /// Results will be skewed toward these topics. At most 5 words can be specified. Nouns work best.
    public static func topicWords(_ words: [String]) -> Self {
        return .init("topics", value: words.joined(separator: ","))
    }
    
    /// Set a hint to the system about the word that appears immediately to the left of the target word in a sentence.
    ///
    /// At this time, only a single word may be specified.
    public static func leftContext(_ context: String) -> Self {
        return .init("lc", value: context)
    }
    
    /// Set a hint to the system about the word that appears immediately to the right of the target word in a sentence.
    ///
    /// At this time, only a single word may be specified.
    public static func rightContext(_ context: String) -> Self {
        return .init("rc", value: context)
    }
    
    /// Include the given per-result metadata.
    public static func include(_ flags: [Datamuse.Result.MetadataFlag]) -> Self {
        return .init("md", value: String(flags.map(\.rawValue)))
    }
    
    /// Limit the number of results to return, clamped to ≤1000.
    public static func max(_ count: Int) -> Self {
        return .init("max", value: count.description, supportsSuggestions: true)
    }
}
