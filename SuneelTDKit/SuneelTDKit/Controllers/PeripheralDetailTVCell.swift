//
//  PeripheralDetailTVCell.swift
//  TDKit
//
//  Created by Suneel on 27/07/22.
//

import UIKit
import CoreBluetooth

class PeripheralDetailTVCell: UITableViewCell {
    
    @IBOutlet weak var peripheralNameLabel: UILabel!
    
    static var nibFile: UINib {
        return UINib(nibName: String(describing: PeripheralDetailTVCell.self), bundle: TD_BUNDLE)
    }
    
    static var reUseIdentifier: String {
        return String(describing: PeripheralDetailTVCell.self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setUpPheripheralDetails(peripheral: CBPeripheral) {
        self.peripheralNameLabel.text = peripheral.name ?? ""
    }
}
