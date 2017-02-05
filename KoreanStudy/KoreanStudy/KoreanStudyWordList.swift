//
//  KoreanStudyWordList.swift
//  KoreanStudy
//
//  Created by bsmith on 2017-01-28.
//  Copyright © 2017 sbrian. All rights reserved.
//

import Foundation

struct KoreanStudyWordList {
    
    var words : Array<KoreanStudyWord>
    
    func count() -> Int {
        return words.count
    }
    
    func wordAt(location: Int) -> KoreanStudyWord {
        return words[location]
    }
    
    func selectWords(count: Int, allowRepeats: Bool, groups: Set<Int>) -> [KoreanStudyWord] {
        let filteredWords : Array<KoreanStudyWord> = self.words.filter({
            let thisWord : KoreanStudyWord = $0
            if (groups.count==0) {
                return true
            }
            return groups.intersection(thisWord.groups).count > 0
        })
        
        if (filteredWords.count==0) {
            return filteredWords
        }
        
        if (allowRepeats) {
            var retVal : [KoreanStudyWord] = []
            for _ in 0 ..< count {
                let index = Int(arc4random_uniform(UInt32(filteredWords.count)))
                retVal.append(filteredWords[index])
                
            }
            return retVal
        } else {
            // This is quite ineffecient, but should be fine for the
            // short lists we will deal with
            var retVal : Set<KoreanStudyWord> = Set<KoreanStudyWord>()
            while true {
                if (retVal.count==filteredWords.count) {
                    return Array(retVal)
                }
                if (retVal.count==count) {
                    return Array(retVal)
                }
                let index = Int(arc4random_uniform(UInt32(filteredWords.count)))
                retVal.insert(filteredWords[index])
            }
        }
    }
    
    static func loadFromFile(path: String) throws -> KoreanStudyWordList {
        var words = [KoreanStudyWord]()
        let data = try String(contentsOfFile: path, encoding: .utf8)
        let strings : Array<String> = data.components(separatedBy: .newlines)
        for str : String in strings {
            if (str=="") {
                continue
            }
            let thisWord = try KoreanStudyWord.parseFromLine(line: str) as KoreanStudyWord?
            if ((thisWord) != nil) {
                words.append(thisWord!)
            }
        }
        return KoreanStudyWordList(words: words)
    }
}
