//
// Created by yang wang on 2017/12/31.
// Copyright (c) 2017 ocean. All rights reserved.
//

import Foundation

class PressInputController: ControllerProtocol {

    var elapsedTime: TimeInterval = 0
    var inputTotalDuration: TimeInterval = 1.0

    public var inputFactor: Float = 0.0
    private var isRunning: Bool = false

    func begin() {
        elapsedTime = 0.0
        inputFactor = 0.0
        isRunning = true
    }

    func end() {
        inputFactor = 0.0
        isRunning = false
    }

    func update(timeSinceLastUpdate: TimeInterval) {
        if isRunning {
            elapsedTime += timeSinceLastUpdate
            inputFactor = Float(elapsedTime / inputTotalDuration)
            inputFactor = inputFactor > 1.0 ? 1.0 : inputFactor
        }
    }
}
