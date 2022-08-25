//
//  TDFeatureCVCell.swift
//  TDKit
//
//  Created by Suneel on 26/07/22.
//

import UIKit

class TDFeatureCVCell: UICollectionViewCell {

    @IBOutlet weak var featureNameLabel: UILabel!
    @IBOutlet weak var featureImageView: UIImageView!
    @IBOutlet weak var featureDetailsView: UIView!
    
    static var nibFile: UINib {
        return UINib(nibName: String(describing: TDFeatureCVCell.self), bundle: TD_BUNDLE)
    }
    
    static var RE_USE_IDENTIFIER: String {
        return String(describing: TDFeatureCVCell.self)
    }
    
    var CAR_ASSET_PATH: String? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    
    func setUpFeatureUI(triggerData: TriggerDetails) {
        guard let carTdPath = self.CAR_ASSET_PATH else { return }
        
         let featureImageFileStr = triggerData.featureImageFile
        let featureImg_FilePath = "\(carTdPath)/\(featureImageFileStr)"
        
        self.featureImageView.contentMode = .scaleAspectFill
        self.featureImageView.image = UIImage(contentsOfFile: featureImg_FilePath)
        self.featureNameLabel.text = triggerData.feature
        let isAudioplayedOrNotValue = triggerData.isAudioPlayed ?? false
        
        self.featureNameLabel.textColor = UIColor.white
        self.featureDetailsView.layer.borderWidth = 0
        self.featureDetailsView.layer.borderColor = UIColor.clear.cgColor
        
        if isAudioplayedOrNotValue {
            self.featureDetailsView.layer.borderWidth = 5
            self.featureDetailsView.layer.borderColor = TDColorCode.primaryColor.cgColor
            self.featureDetailsView.layer.masksToBounds = true
        }
        
        
    }

}
