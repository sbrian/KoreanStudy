//
//  KoreanStudyWord.swift
//  KoreanStudy
//
//  Created by bsmith on 2017-01-28.
//  Copyright © 2017 sbrian. All rights reserved.
//

import Foundation

struct KoreanStudyWord: Hashable {
    
    var koreanWord: String
    
    var englishWord: String
    
    var groups: Set<Int>
    
    var hashValue: Int {
        return (self.koreanWord + self.englishWord).hash
    }
    
    static func ==(lhs: KoreanStudyWord, rhs: KoreanStudyWord) -> Bool {
        return lhs.koreanWord == rhs.koreanWord
            && lhs.englishWord == rhs.englishWord
    }
    
    func hasGroups(groups: Set<Int>) -> Bool {
        return false
    }
    
    static func parseFromLine(line: String) throws -> KoreanStudyWord? {
        let l = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if l.hasPrefix("#") {
            return nil
        }
        if let g = l.capturedGroups(withRegex: "^([ -~]+) (.+) ([0-9,]+)\\s*$") as [String]? {
            let groups2 = Set(g[2].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).components(separatedBy: ",").map({return Int("\($0)")!}))
            return KoreanStudyWord(koreanWord: g[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), englishWord: g[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), groups: groups2)
        } else {
            return nil
        }
    }
}

extension String {
    func capturedGroups(withRegex pattern: String) -> [String] {
        var results = [String]()

        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return results
        }
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.characters.count))
        
        guard let match = matches.first else { return results }
        
        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return results }
        
        for i in 1...lastRangeIndex {
            let capturedGroupIndex = match.rangeAt(i)
            let matchedString = (self as NSString).substring(with: capturedGroupIndex)
            results.append(matchedString)
        }
        
        return results
    }
}
