//
//  KoreanStudyPass.swift
//  KoreanStudy
//
//  Created by bsmith on 2017-01-29.
//  Copyright © 2017 sbrian. All rights reserved.
//

import Foundation

enum KoreanStudyPassType {
    case KoreanToEnglish
    case EnglishToKorean
}

struct KoreanStudyPass {

    let type : KoreanStudyPassType
    
    let words : [KoreanStudyWord]
    
    var pos : Int = 0
    
    init(words: [KoreanStudyWord],
        type: KoreanStudyPassType) {
        self.words = words
        self.type = type
        self.pos = 0
    }
    
    func wordCount() -> Int {
        return words.count
    }
    
    func hasMore() -> Bool {
        return self.pos < words.count
    }
    
    func nextQuery() -> String {
        if (type == KoreanStudyPassType.KoreanToEnglish) {
            return words[self.pos].koreanWord
        } else {
            return words[self.pos].englishWord
        }
    }
    
    mutating func nextResponse() -> String {
        let thisPos : Int = self.pos
        self.pos = self.pos + 1
        if (type == KoreanStudyPassType.KoreanToEnglish) {
            return words[thisPos].englishWord
        } else {
            return words[thisPos].koreanWord
        }
    }
}
