//
//  SavedAlbumsViewController.swift
//  iosApp
//
//  Created by Valdo on 01.03.2025.
//

import UIKit

class SavedAlbumsViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(handleSharedURL(_:)), name: .sharedURLReceived, object: nil)

        // Do any additional setup after loading the view.
    }
    
    @objc private func handleSharedURL(_ notification: Notification) {
        if let url = notification.object as? String {
            print("📌 ViewController received shared URL: \(url)")
            label.text = url
        }
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
