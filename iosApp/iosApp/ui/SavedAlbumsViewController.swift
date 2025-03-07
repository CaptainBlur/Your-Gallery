//
//  SavedAlbumsViewController.swift
//  iosApp
//
//  Created by Valdo on 01.03.2025.
//

import UIKit
import AVKit
import shared
import Kingfisher

class SavedAlbumsViewController: UIViewController {

    @IBOutlet weak private var label: UILabel!
    
    var startLink: String = String()
    private let dp = DataParser()
    private let colorScheme = MediaContainerType.bunkr.colorScheme
    
    private var performingParsing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = startLink
        Native().sl.en()
        
        view.backgroundColor = colorScheme.surfaceContainerLowest.uiColor()
        NotificationCenter.default.addObserver(self, selector: #selector(handleSharedURL(_:)), name: .sharedURLReceived, object: nil)
         
        checkAvailableLink()
//        present(MediaContainerViewController(dp.testMediaContainer), animated: true)
    }

    
    @IBAction func itemButtonAction() {
        startLink =
//            "https://bunkr.si/f/WanpgCl4bG8V7" //cristyren short
//            "https://bunkr.cr/v/xbsUbrPczwB09" //longer vid
//            "https://bunkr.pk/f/VDFUE3kAMayGo" //selti
            "https://bunkr.site/f/bsXOm7h9zGvSC" //diana
        checkAvailableLink()
    }
    
    @IBAction func albumButtonAction(_ sender: UIButton) {
        startLink =
//            "https://bunkr.cr/a/Zix5amPZ" //ortega
            "https://bunkr.si/a/J0wRO0lB" //mirari
//            "https://bunkr.cr/a/bAJi6vwd" //kim
        checkAvailableLink()
    }
}

extension SavedAlbumsViewController{
    private func checkAvailableLink(){
        guard !startLink.isEmpty, !performingParsing else { return }
        
        Task {
            performingParsing = true
            do {
                // Call the function and unwrap its result
                guard let result = try await dp.parseData(url: startLink) else {
                    Native().sl.w(msg: "Error: getting parsed data")
                    performingParsing = false
                    return
                }
                
                if let item = result as? MediaItem{
                    present(PlayerViewController(item), animated: true)
                } else if let container = result as? MediaContainer{
                    Native().sl.i(msg: "entering media container")
                    present(MediaContainerViewController(container), animated: true)
//                    navigationController?.pushViewController(MediaContainerViewController(container), animated: true)
                }
            } catch {
                Native().sl.s(msg: "Error: \(error.localizedDescription)")
            }
            performingParsing = false
        }
    }
    
    @objc private func handleSharedURL(_ notification: Notification) {
        if let url = notification.object as? String {
            Native().sl.f(msg: "ViewController received shared URL: \(url)")
            startLink = String(url.dropFirst(4))
            label.text = startLink
        }
    }
}

