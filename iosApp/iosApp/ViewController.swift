//
//  ViewController.swift
//  iosApp
//
//  Created by Valdo on 24.02.2025.
//

import UIKit
import AVKit
import shared

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func addSampleText(){
        view.backgroundColor = .white
        
        //let text = Greeting().greet()
        let text = "text"
        
        // Create a UITextView
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textColor = .black
        textView.backgroundColor = .lightGray
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.darkGray.cgColor
        
        // Add UITextView to the view
        view.addSubview(textView)
        
        // Set Constraints
        NSLayoutConstraint.activate([
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            textView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @IBAction func PlayAction(_ sender: Any) {
        let bunkrString = "https://c.bunkr-cache.se/Zpd1TcX70MiMS8zp/0h1ctt9b5cf3sz6sad9ce_source-R8qCdEAs.mp4"
        let pixeldrainString = "https://pixeldrain.com/api/file/mwfg67nR?download"
        let pd2 = "https://pixeldrain.com/api/file/jDBNzpVq?download"
        
        let url = URL(string: pixeldrainString)!
        let avplayer = AVPlayer(url: url)
        let avController = AVPlayerViewController()
        avController.player = avplayer
        present(avController, animated: true, completion: nil)
    }
}

