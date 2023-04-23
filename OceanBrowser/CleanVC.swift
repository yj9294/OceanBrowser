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
            if progress == 0 {
                return
            }
            if progress > 1.0 {
                progress = 1.0
                launched()
            }
            titleLabel.text = "cleaning...\(Int(progress * 100))%"

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
        duration = 16.0
        timer.schedule(deadline: .now(), repeating: 0.01)
        timer.setEventHandler {
            DispatchQueue.main.async {
                self.progress += (0.01 / self.duration)
            }
            if self.progress > 3 / 16.0, GADUtil.share.isLoaded(.interstitial) {
                self.duration = 0.1
            }
        }
        timer.resume()
        GADUtil.share.load(.interstitial)
        GADUtil.share.load(.native)
    }
    
    func launched() {
        progress = 0.0
        timer.suspend()
        GADUtil.share.show(.interstitial, from: self) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.progress == 0.0 {
                    self.dismiss(animated: true) {
                        if rootVC?.selectedIndex == 1 {
                            self.completionHandle?()
                        }
                    }
                }
            }
        }
    }

}
