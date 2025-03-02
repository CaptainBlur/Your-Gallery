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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = startLink
        
        view.backgroundColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(handleSharedURL(_:)), name: .sharedURLReceived, object: nil)

        // Do any additional setup after loading the view.
    }
    
    @objc private func handleSharedURL(_ notification: Notification) {
        if let url = notification.object as? String {
            print("📌 ViewController received shared URL: \(url)")
            label.text = String(url.dropFirst(4))
        }
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        let fieldText = label.text!
        
        Task {
            do {
                // Call the function and unwrap its result
                let result = try await dp.parseData(url: fieldText) as? MediaItem

                // Ensure the URL is valid
                guard
                    let mediaItem = result,
                    let videoUrl = URL(string: mediaItem.resolvedContentLink)
                else {
                    print("❌ Error: Invalid URL format")
                    return
                }

                let avplayer = createAVPlayerWithHeaders(videoUrl: videoUrl.absoluteString, headers: mediaItem.headers)

                let avController = AVPlayerViewController()
                avController.player = avplayer
                present(avController, animated: true, completion: nil)
            } catch {
                print("❌ Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func createAVPlayerWithHeaders(videoUrl: String, headers: [String: String]) -> AVPlayer {
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

        return player
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
