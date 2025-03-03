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
        Native().sl.en()
        
        view.backgroundColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(handleSharedURL(_:)), name: .sharedURLReceived, object: nil)

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
                let result = try await dp.parseData(url: fieldText) as? MediaItem
//                Thread.callStackSymbols.forEach{print($0)}

                // Ensure the URL is valid
                guard
                    let mediaItem = result,
                    let videoUrl = URL(string: mediaItem.resolvedContentLink)
                else {
                    Native().sl.s(msg: "Error: Invalid URL format")
                    return
                }
                Native().sl.i(msg: "launching player")

//                let custonUrl = "https://oo359m.cloudatacdn.com/u5kjzqj2vdflsdgge6tf6oimi4bx2cre4zzgsnr663golfzirzl53zpmfctq/850lr32jvg~m345qtmLYI?token=idy91504aqijguspmn2lbh41&expiry=1740964846475"
                let avplayer = createAVPlayerWithHeaders(videoUrl: videoUrl.absoluteString, headers: mediaItem.headers)

                let avController = AVPlayerViewController()
                avController.player = avplayer
                present(avController, animated: true, completion: nil)
            } catch {
                Native().sl.s(msg: "Error: \(error.localizedDescription)")
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
