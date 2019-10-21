//
//  StopWatch.swift
//  StopWatch
//
//  Created by Shubhang Dixit on 19/10/19.
//  Copyright © 2019 Shubhang. All rights reserved.
//

// Pleae note :  Timers have a resolution of 50-100 ms (0.05 to 0.1 seconds). Timers are not realtime. They depend on the run loop they are attached to, and if the run loop gets busy, the firing of the timer gets delays. So using timers. Instead of trying to increment a counter each time timer fires, I am recording the start time when initiate the timer, and then doing some math to figure out how much time has transpired, also recording the paused time to avoid pause errors


import Foundation
import UIKit

protocol StopwatchDelegate {
    func minutesDidChange(to value : String)
    func secondsDidChange(to value : String)
    func milliSecondsDidChange(to value : String)
}

enum StopWatchState : String {
    case paused = "p", running = "r"
}

class Stopwatch: NSObject, NSCoding {
    
    static let shared = Stopwatch.loadArchived()
    
    var delegate : StopwatchDelegate? {
        didSet {
            if state == .running {
                timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
            } else {
                startTime = nil
                lapTime = nil
                counter()
            }
        }
    }
    var lapManager = LapManager(withLapList: [])
    
    private var startTime: Date?
    private var lapTime: Date?
    
    var timer = Timer()
    var state : StopWatchState = .paused
    
    var minutes : Int {
        didSet {
            delegate?.minutesDidChange(to: Stopwatch.timeIntervalString(for: minutes))
        }
    }
    var seconds : Int {
        didSet {
            delegate?.secondsDidChange(to: Stopwatch.timeIntervalString(for: seconds))
        }
    }
    var miliSeconds : Int {
        didSet {
            delegate?.milliSecondsDidChange(to: Stopwatch.timeIntervalString(for: miliSeconds))
        }
    }
    
    //MARK: Types
    
    struct PropertyKey {
        static let laps = "laps"
        static let startTime = "startTime"
        static let lapTime = "lapTime"
        static let state = "state"
        static let lastPausedTimeInterval = "lastPausedTimeInterval"
        static let lastPausedLapTime = "lastPausedLapTime"
    }
    
    override init() {
        minutes = 0
        seconds = 0
        miliSeconds = 0
    }
    
    var lastPausedTimeInterval : TimeInterval = 0.0
    var lastPausedLapTime : TimeInterval = 0.0
    
    var elapsedTime: TimeInterval {
        if let startTime = self.startTime {
            return -startTime.timeIntervalSinceNow + lastPausedTimeInterval
        } else {
            return lastPausedTimeInterval
        }
    }
    
    var elapsedLapTime: TimeInterval {
        if let startTime = self.lapTime {
            return -startTime.timeIntervalSinceNow + lastPausedLapTime
        } else {
            return lastPausedLapTime
        }
    }
    
    var elapsedLapTimeAsString: String {
        return String(format: "%02d:%02d.%02d",
                      Int(elapsedLapTime / 60), Int(elapsedLapTime.truncatingRemainder(dividingBy: 60)), Int((elapsedLapTime * 60).truncatingRemainder(dividingBy: 60)))
    }
    
    
    @objc func counter() {        
        miliSeconds = Int((elapsedTime * 60).truncatingRemainder(dividingBy: 60))
        let sec = Int(elapsedTime.truncatingRemainder(dividingBy: 60))
        if sec > seconds || sec == 0 {
            seconds = sec
        }
        let min = Int(elapsedTime / 60)
        if min >= 90 {
            timer.invalidate()
        } else if min > minutes {
            minutes = min
        }
    }
    
    var isRunning: Bool {
        return startTime != nil
    }
    
    func start() {
        startTime = Date()
        lapTime = Date()
        timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
        state = .running
    }
    
    func reset() {
        startTime = nil
        lapTime = nil
        lastPausedTimeInterval = 0.0
        lastPausedLapTime = 0.0
        minutes = 0
        seconds = 0
        miliSeconds = 0
        state = .paused
        lapManager.reset()
    }
    
    func recordLap() {
        lastPausedLapTime = 0.0
        lapManager.addLap(forTimeStamp: elapsedLapTimeAsString)
        lapTime = Date()
    }
    
    func pause() {
        timer.invalidate()
        state = .paused
        lastPausedTimeInterval = elapsedTime
        lastPausedLapTime = elapsedLapTime
    }
    
    func getLaps() -> [String] {
        return lapManager.laps.reversed()
    }
    
    class func timeIntervalString(for timeValue : Int) -> String {
        if timeValue < 10 {
            return "0" + String(timeValue)
        }
        return String(timeValue)
    }
    
    
    //MARK: NSCoding
    
    class func loadArchived() -> Stopwatch {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Stopwatch.ArchiveURL.path) as? Stopwatch ?? Stopwatch()
    }
    
    func saveData() {
       NSKeyedArchiver.archiveRootObject(self, toFile: Stopwatch.ArchiveURL.path)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(lapManager.laps, forKey: PropertyKey.laps)
        aCoder.encode(startTime, forKey: PropertyKey.startTime)
        aCoder.encode(lapTime, forKey: PropertyKey.lapTime)
        aCoder.encode(state.rawValue, forKey: PropertyKey.state)
        aCoder.encode(String(lastPausedLapTime), forKey: PropertyKey.lastPausedLapTime)
        aCoder.encode(String(lastPausedTimeInterval), forKey: PropertyKey.lastPausedTimeInterval)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        guard let laps = aDecoder.decodeObject(forKey: PropertyKey.laps) as? [String] else {
            return
        }
        lapManager = LapManager.init(withLapList: laps)
        startTime = aDecoder.decodeObject(forKey: PropertyKey.startTime) as? Date
        lapTime = aDecoder.decodeObject(forKey: PropertyKey.lapTime) as? Date
        let stateRawValue = aDecoder.decodeObject(forKey: PropertyKey.state) as? String ?? "p"
        state = StopWatchState.init(rawValue: stateRawValue) ?? StopWatchState.paused
        let klastPausedTimeInterval = aDecoder.decodeObject(forKey: PropertyKey.lastPausedTimeInterval) as? String ?? "0.0"
        lastPausedTimeInterval = Double(klastPausedTimeInterval) ?? 0.0
        let klastPausedLapTime = aDecoder.decodeObject(forKey: PropertyKey.lastPausedLapTime) as? String ?? "0.0"
        lastPausedLapTime = Double(klastPausedLapTime) ?? 0.0
    }
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("stopwatch")
    
}
