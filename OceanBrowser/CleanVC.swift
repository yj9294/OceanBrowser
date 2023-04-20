//
//  CleanVC.swift
//  OceanBrowser
//
//  Created by yangjian on 2023/4/19.
//

import UIKit

class CleanVC: UIViewController {
    
    var completionHandle:(()->Void)? = nil
    
    lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource()
        return timer
    }()
    
    var progress: Double = 0.0 {
        didSet {
            titleLabel.text = "cleaning...\(Int(progress * 100))%"
            if progress > 1.0 {
                progress = 1.0
                timer.cancel()
                self.dismiss(animated: true) {
                    self.completionHandle?()
                }
            }
        }
    }
    
    var duration = 3.0

    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        BrowserUtil.shared.clean(from: self)
        launching()
    }
    
    func launching() {
        progress = 0
        duration = 3.0
        timer.schedule(deadline: .now(), repeating: 0.01)
        timer.setEventHandler {
            DispatchQueue.main.async {
                self.progress += (0.01 / self.duration)
            }
        }
        timer.resume()
    }

}
