//
//  BrowseTabViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit

class BrowseTabViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // setting view's background color
        view.backgroundColor = .white
        
        // scroll edge initialization for navBar
        navigationController?.navigationBar.scrollEdgeAppearance = .init()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
