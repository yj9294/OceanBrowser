//
//  LaunchVC.swift
//  OceanBrowser
//
//  Created by yangjian on 2023/4/18.
//

import UIKit

class LaunchVC: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    
    lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource()
        return timer
    }()
    
    var progress: Double = 0.0 {
        didSet {
            progressView.progress = Float(progress)
            if progress > 1.0 {
                launched()
            }
        }
    }
    
    var duration = 16.0

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        launching()
    }

}

extension LaunchVC {
    
    func launching() {
        GADUtil.share.load(.interstitial)
        GADUtil.share.load(.native)
        progress = 0
        duration = 16.0
        timer.schedule(deadline: .now(), repeating: 0.01)
        timer.setEventHandler {
            DispatchQueue.main.async {
                self.progress += (0.01 / self.duration)
            }
            
            if self.progress > 3.0 / 16.0, GADUtil.share.isLoaded(.interstitial) {
                self.duration = 0.1
            }
        }
        timer.resume()
    }
    
    func launched() {
        progress = 0.0
        timer.suspend()
        GADUtil.share.show(.interstitial) { _ in
            if self.progress == 0.0 {
                rootVC?.selectedIndex = 1
            }
        }
    }
    
}
