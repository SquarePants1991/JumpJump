//
//  ScoreController.swift
//  BumpBump
//
//  Created by yang wang on 2018/1/2.
//  Copyright © 2018年 ocean. All rights reserved.
//

import Foundation

let kScoreSaveKey = "kScoreSaveKey"

class ScoreController {
    func saveScore(newScore: Int) {
        var needSaveScore = true
        if let score = UserDefaults.standard.value(forKey: kScoreSaveKey) as? Int, newScore < score {
            needSaveScore = false
        }
        if needSaveScore {
            UserDefaults.standard.set(newScore, forKey: kScoreSaveKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    func isNewRecord(newScore: Int) -> Bool {
        if let score = UserDefaults.standard.value(forKey: kScoreSaveKey) as? Int {
            return newScore > score
        }
        return true
    }
}
