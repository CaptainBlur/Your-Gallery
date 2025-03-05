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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = startLink
        Native().sl.en()
        
        view.backgroundColor = colorScheme.surfaceContainerLowest.uiColor()
        NotificationCenter.default.addObserver(self, selector: #selector(handleSharedURL(_:)), name: .sharedURLReceived, object: nil)
         
//        present(MediaContainerViewController(dp.testMediaContainer), animated: true)
    }
    
    @objc private func handleSharedURL(_ notification: Notification) {
        if let url = notification.object as? String {
            Native().sl.f(msg: "ViewController received shared URL: \(url)")
            label.text = String(url.dropFirst(4))
        }
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        let fieldText = label.text!
        
        Task {
            do {
                // Call the function and unwrap its result
                guard let result = try await dp.parseData(url: fieldText) else {
                    Native().sl.w(msg: "Error: getting parsed data")
                    return
                }
                
                if let item = result as? MediaItem{
                    guard
                        let videoUrl = URL(string: item.resolvedContentLink)
                    else {
                        Native().sl.s(msg: "Error: Invalid URL format")
                        return
                    }
                    Native().sl.i(msg: "launching player")
                    launchPlayer(videoUrl: videoUrl.absoluteString, headers: item.headers)
                    
                } else if let container = result as? MediaContainer{
                    Native().sl.i(msg: "entering media container")
                    present(MediaContainerViewController(container), animated: true)
                }
            } catch {
                Native().sl.s(msg: "Error: \(error.localizedDescription)")
            }
        }
    }
    

}


extension UIViewController{
    
    func launchPlayer(videoUrl: String, headers: [String: String]){
        guard let url = URL(string: videoUrl) else {
            fatalError("Invalid URL")
        }

        // Set AVAsset HTTP headers
        let assetOptions: [String: Any] = [
            "AVURLAssetHTTPHeaderFieldsKey": headers
        ]

        // Create an AVURLAsset with custom headers
        let asset = AVURLAsset(url: url, options: assetOptions)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        
        let avController = AVPlayerViewController()
        avController.player = player
        present(avController, animated: true, completion: nil)
    }
}
