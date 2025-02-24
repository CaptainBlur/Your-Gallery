//
//  ViewController.swift
//  iosApp
//
//  Created by Valdo on 24.02.2025.
//

import UIKit
import shared

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let text = Greeting().greet()
        
        // Create a UITextView
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textColor = .white
        textView.backgroundColor = .systemGroupedBackground
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        
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
}

