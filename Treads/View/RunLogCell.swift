//
//  RunLogCell.swift
//  Treads
//
//  Created by developer on 11.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit

class RunLogCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var runDurationLbl: UILabel!
    @IBOutlet weak var totalDistanceLbl: UILabel!
    @IBOutlet weak var averagePaceLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func configure(run: Run) {
        runDurationLbl.text = run.duration.formatTimeDurationToString()
        totalDistanceLbl.text = "\(run.distance.meters(places: 2)) km"
        averagePaceLbl.text = run.pace.formatTimeDurationToString()
        dateLbl.text = run.date?.getDateString()
    }
}
