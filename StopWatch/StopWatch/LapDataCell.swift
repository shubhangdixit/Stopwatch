//
//  LapDataCell.swift
//  StopWatch
//
//  Created by Shubhang Dixit on 20/10/19.
//  Copyright © 2019 Shubhang. All rights reserved.
//

import UIKit

class LapDataCell: UITableViewCell {
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        indexLabel.setFixedWidthFont(forWeight: .regular)
        timeLabel.setFixedWidthFont(forWeight: .regular)
    }
    
    func configureCell(forIndex index : Int, andTime time : String) {
        self.indexLabel.text = "Lap " + String(index)
        self.timeLabel.text = time
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
