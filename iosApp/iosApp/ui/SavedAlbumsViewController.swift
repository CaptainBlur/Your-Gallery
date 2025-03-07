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


    @IBAction func buttonAction(_ sender: UIButton) {
//        navigationController?.pushViewController(MediaContainerViewController(dp.testMediaContainer), animated: true)
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
                    return
                }
                
                if let item = result as? MediaItem{
//                    launchPlayer(item: item)
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


extension UIViewController{
//    func launchPlayer(item: MediaItem){
//        Native().sl.i(msg: "launching player for link: \(item.resolvedContentLink)")
//        present(PlayerViewController(), animated: true, completion: nil)
//    }
//    func launchPlayer(container: MediaContainer){
//        Native().sl.i(msg: "launching player for container: \(container.remoteContainerLink)")
//        present(PlayerViewController(), animated: true, completion: nil)
//    }
}
