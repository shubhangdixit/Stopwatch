//
//  LapManager.swift
//  StopWatch
//
//  Created by Shubhang Dixit on 20/10/19.
//  Copyright © 2019 Shubhang. All rights reserved.
//

import Foundation

class LapManager {
    
    var laps : [String] = []
    var count : Int {
        return laps.count
    }
    
    init(withLapList list : [String]) {
        self.laps = list
    }
    
    func addLap(forTimeStamp time : String) {
        laps.append(time)
    }
    
    func reset() {
        laps = []
    }
    
}
