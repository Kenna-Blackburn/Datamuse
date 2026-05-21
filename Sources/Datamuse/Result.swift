//
//  Result.swift
//  Datamuse
//
//  Created by Kenna Blackburn on 5/20/26.
//

import Foundation

extension Datamuse {
    public struct Result: Decodable {
        public let string: String
        
        public let score: Int?
        public let definitions: [String]?
        public let syllableCount: Int?
        
        public let pronounciation: String?
        public let frequency: Double?
        public let partsOfSpeech: [PartOfSpeech]?
        
        public let _tags: [String]?
        
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.string = try container.decode(String.self, forKey: .string)
            
            self.score = try container.decodeIfPresent(Int.self, forKey: .score)
            self.definitions = try container.decodeIfPresent([String].self, forKey: .definitions)
            self.syllableCount = try container.decodeIfPresent(Int.self, forKey: .syllableCount)
            
            let tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
            self._tags = tags.isEmpty ? nil : tags
            
            func tag<T>(_ id: String, _ transform: (Substring) -> T?) -> T? {
                let prefix = id + ":"
                guard let tag = tags.first(where: { $0.hasPrefix(prefix) }) else {
                    return nil
                }
                return transform(tag.trimmingPrefix(prefix))
            }
            
            self.pronounciation = tag("pron", String.init)
            
            self.frequency = tag("f", Double.init)
            
            let partsOfSpeech = tags.compactMap(PartOfSpeech.init)
            self.partsOfSpeech = partsOfSpeech.isEmpty ? nil : partsOfSpeech
        }
        
        private enum CodingKeys: String, CodingKey {
            case string        = "word"
            case score         = "score"
            case definitions   = "defs"
            case syllableCount = "numSyllables"
            case tags          = "tags"
        }
    }
}

extension Datamuse.Result {
    public enum MetadataFlag: Character {
        case definitions   = "d"
        case partsOfSpeech = "p"
        case syllableCount = "s"
        case pronunciation = "r"
        case frequency     = "f"
    }
}

extension Datamuse.Result {
    public enum PartOfSpeech: String {
        case noun      = "n"
        case verb      = "v"
        case adjective = "adj"
        case adverb    = "adv"
        case unknown   = "u"
    }
}
