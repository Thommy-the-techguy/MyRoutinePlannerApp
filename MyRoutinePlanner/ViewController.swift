//
//  ViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}

extension UIViewController {
    var statusBarHeight: CGFloat {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let height = scene.statusBarManager?.statusBarFrame.height
        else {
            return 0
        }
        return height
    }
}
