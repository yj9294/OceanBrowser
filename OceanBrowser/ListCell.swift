//
//  ListCell.swift
//  OceanBrowser
//
//  Created by yangjian on 2023/4/19.
//

import UIKit

class ListCell: UICollectionViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var closeHandle: (()->Void)? = nil

    
    @IBAction func closeAction() {
        closeHandle?()
    }

    var item: BrowserItem? = nil {
        didSet {
            title.text = item?.webView.url?.absoluteString.replacingOccurrences(of: "https://www.", with: "")
            closeButton.isHidden = BrowserUtil.shared.count == 1
        
            self.borderColor = UIColor(named: "#2772F7")!
            
            if BrowserUtil.shared.item == item {
                self.borderWidth = 1
                self.borderColor = UIColor.black
            } else {
                self.borderWidth = 1
                self.borderColor = UIColor(named: "#D8D8D8")!
            }
        }
    }

}
