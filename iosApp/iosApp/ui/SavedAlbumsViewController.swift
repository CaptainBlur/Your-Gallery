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
    @IBOutlet weak var itemButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    
    var startLink: String = String()
    private let parserActor = ParserActor()
    private let colorScheme = MediaContainerType.default_.colorScheme
    private let playerCache = PlayerVCCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Native.shared.sl.en()
        setupNavBar()
        
        label.text = startLink
        
        view.backgroundColor = colorScheme.surfaceContainerLowest.uiColor()
        NotificationCenter.default.addObserver(self, selector: #selector(handleSharedURL(_:)), name: .sharedURLReceived, object: nil)
         
//        checkAvailableLink()
//        albumButtonAction(UIButton())
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(itemLongPress))
        self.itemButton.addGestureRecognizer(longPress)
        
        self.albumButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(albumLongPress)))
    }

    @objc func itemLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            startLink =
            "https://bunkr.cr/f/Ly3zQuAQWw5CK" //ritori
            checkAvailableLink()
        }
    }
    
    @IBAction func labelButtonAction(_ sender: Any) {
        checkAvailableLink()
    }
    
    
    @IBAction func itemButtonAction() {
        startLink =
//            "https://bunkr.si/f/WanpgCl4bG8V7" //cristyren short
//            "https://bunkr.cr/v/xbsUbrPczwB09" //longer vid
//            "https://bunkr.pk/f/VDFUE3kAMayGo" //selti
//            "https://bunkr.site/f/bsXOm7h9zGvSC" //diana
//        "https://cdn-fries.bunkr.ru/2023-08-08_at_21-40_id_545336713568854016-YQZx7ej4.mp4" //shawty
//        "https://bunkr.cr/f/Mrf66nQAxSx1T" //kait
//        "https://bunkr.cr/f/RYvrs1I7HCCyi" //kait 2
        "https://bunkr.cr/f/RwFU2mpje32yh" //ritori
        checkAvailableLink()
    }
    
    @IBAction func albumButtonAction(_ sender: UIButton) {
        startLink =
//        "https://bunkr.cr/a/Zix5amPZ" //ortega
//        "https://bunkr.si/a/J0wRO0lB" //mirari
        "https://bunkr.cr/a/bAJi6vwd" //kim
//        "https://bunkr.fi/a/L7Drn4GL" //girl
//        "https://bunkr.si/a/XOGKz13p" //hastya cam
        
//        "https://bunkr.cr/a/Uz0c4pOi" // kiko w photos
//        "https://bunkr.cr/a/ZzBMUGJU" //kait only photos
//        "https://bunkr.cr/a/FVE7ci9d" //ritori photos lot
//        "https://bunkr.cr/a/6vgyxAUr" //ritori videos
        
        checkAvailableLink()
    }
    
    @objc func albumLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            startLink =
            "https://pixeldrain.com/l/j5G25RUJ" //pixeldrain kotya
            checkAvailableLink()
        }
    }
    
    var itemState: UIMenuElement.State = .off
    
    private func setupNavBar(){
        navigationItem.title = "Saved albums"
        
        let refreshAction = UIAction(title: "Refresh", attributes: .keepsMenuPresented, state: .on) { (action) in
            Native.shared.sl.w(obj: action.state)
        }
        refreshAction.state = .off
        
        let refreshMenuItem = UIMenu(title: "", options: .displayInline, children: [refreshAction])
//        refreshMenuItem.options = .
        
        let config = UIImage.SymbolConfiguration(pointSize: 19).applying(UIImage.SymbolConfiguration(hierarchicalColor: colorScheme.primary.uiColor()))
        let ellipsisImage = UIImage(systemName: "ellipsis.circle", withConfiguration: config)!
        
        let menu = createMenu()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: ellipsisImage, menu: createMenu())
    }
    
    func createMenu() -> UIMenu {
        Native.shared.sl.en()
        let toggleAction = UIAction(
            title: "Lock resolution",
            state: itemState
        ) { [weak self] action in
            guard let self = self else { return }
            
            // Toggle state
            self.itemState = (self.itemState == .off) ? .on : .off
            
            // Update the menu dynamically
            self.updateMenu()
        }

        return UIMenu(children: [toggleAction])
    }

    func updateMenu() {
        navigationItem.rightBarButtonItem?.menu = createMenu()  // Refresh menu
    }
}

extension SavedAlbumsViewController{
    private func checkAvailableLink(){
        guard !startLink.isEmpty else { return }
        
        Task{
            await parserActor.parseData(url: startLink){[weak self] result in
                if let item = result as? MediaItem{
                    self?.present(PlayerViewController(item, controllersCache: self?.playerCache ?? PlayerVCCache()), animated: true)
                }
                else if let container = result as? MediaContainer{
                    Native.shared.sl.i(msg: "entering media container")
//                    self?.present(MediaContainerViewController(container), animated: true)
//                    self?.navigationController?.present(MediaContainerViewController(container), animated: true)
                    
                    let navController = UINavigationController(rootViewController: MediaContainerViewController(container))
                    self?.present(navController, animated: true)
                }
            }
        }
    }
    
    @objc private func handleSharedURL(_ notification: Notification) {
        if let url = notification.object as? String {
            Native.shared.sl.f(msg: "ViewController received shared URL: \(url)")
            startLink = String(url.dropFirst(4))
            label.text = startLink
        }
    }
}

extension SavedAlbumsViewController{
    actor ParserActor{
        private let dp = DataParser()
        private var performingParsing = false
        
        func parseData(url: String, _ onComplete: @MainActor @escaping (Any?)->Void){
            guard !performingParsing else { return }
            Task{
                performingParsing = true
                do{
                    let result = try await dp.parseData(url: url)
                    await onComplete(result)
                    performingParsing = false
                } catch {
                    Native.shared.sl.s(msg: "Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
