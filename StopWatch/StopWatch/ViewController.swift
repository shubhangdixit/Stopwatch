//
//  ViewController.swift
//  StopWatch
//
//  Created by Shubhang Dixit on 17/10/19.
//  Copyright © 2019 Shubhang. All rights reserved.
//

import UIKit

enum StopWatchButtonStyles : String {
    case start = "Start", stop = "Stop", lap = "Lap", reset = "Reset"
    func color() -> UIColor {
        switch self {
        case .start:
            return UIColor.green
        case .stop:
            return UIColor.red
        default:
            return UIColor.darkGray
        }
    }
}

class ViewController: UIViewController, StopwatchDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var milliSecondLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var lapTimeLabel: UILabel!
    
    @IBOutlet weak var lapsTableView: UITableView!
    
    @IBOutlet weak var lapAndResetButton: UIButton!
    @IBOutlet weak var startStopButton: UIButton!
    
    let stopwatch = Stopwatch.shared
    
    // MARK:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUIElements()
        stopwatch.delegate = self
        lapsTableView.delegate = self
        lapsTableView.dataSource = self
        
        initialSetupForButton()
    }
    
    // MARK: UI
    
    func configureUIElements() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        tableViewWidthConstraint.constant = screenWidth < screenHeight ? screenWidth : screenHeight
        
        roundedCorner(forView: startStopButton)
        roundedCorner(forView: lapAndResetButton)
        
        self.title = "Stopwatch"
        
        milliSecondLabel.setFixedWidthFont(forWeight: .ultraLight)
        secondsLabel.setFixedWidthFont(forWeight: .ultraLight)
        minuteLabel.setFixedWidthFont(forWeight: .ultraLight)
        lapTimeLabel.setFixedWidthFont(forWeight: .regular)
    }
    
    func roundedCorner(forView rView : UIView) {
        rView.layer.cornerRadius = 30
        rView.layer.masksToBounds = true
    }
    
    func changeStyle(forButton button : UIButton, toStyle style : StopWatchButtonStyles) {
        button.setTitle(style.rawValue, for: .normal)
        button.setTitleColor(style.color(), for: .normal)
    }
    
    func initialSetupForButton() {
        switch stopwatch.state {
        case .running:
            changeStyle(forButton: startStopButton, toStyle: .stop)
            changeStyle(forButton: lapAndResetButton, toStyle: .lap)
        case .paused:
            changeStyle(forButton: startStopButton, toStyle: .start)
            changeStyle(forButton: lapAndResetButton, toStyle: .reset)
        }
        stopwatch.counter()
    }
    
    // MARK: Buttons
    
    @IBAction func startStopButtonAction(_ sender: Any) {
        switch stopwatch.state {
        case .running:
            stopwatch.pause()
            changeStyle(forButton: startStopButton, toStyle: .start)
            changeStyle(forButton: lapAndResetButton, toStyle: .reset)
        case .paused:
            stopwatch.start()
            changeStyle(forButton: startStopButton, toStyle: .stop)
            changeStyle(forButton: lapAndResetButton, toStyle: .lap)
        }
    }
    
    @IBAction func resetLapButtonAction(_ sender: Any) {
        
        switch stopwatch.state {
        case .running:
            stopwatch.recordLap()
        case .paused:
            stopwatch.reset()
        }
        lapsTableView.reloadData()
    }
    
    
    // MARK: Stopwatch Delegate functions
    
    func minutesDidChange(to value: String) {
        minuteLabel.text = value + ":"
    }
    
    func secondsDidChange(to value: String) {
        secondsLabel.text = value + "."
    }
    
    func milliSecondsDidChange(to value: String) {
        milliSecondLabel.text = value
        lapTimeLabel.text = stopwatch.elapsedLapTimeAsString
        
    }
    
    // MARK: Table view functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stopwatch.lapManager.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LapDataCell") as? LapDataCell {
            cell.configureCell(forIndex: stopwatch.lapManager.count - indexPath.row, andTime: stopwatch.getLaps()[indexPath.row])
            return cell
        }
        return UITableViewCell.init()
    }
}

