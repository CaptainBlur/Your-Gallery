//
//  ShareViewController.swift
//  YourGallery
//
//  Created by Valdo on 01.03.2025.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    override func isContentValid() -> Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let attachments = item.attachments {
                for provider in attachments {
                    if provider.hasItemConformingToTypeIdentifier("public.url") {
                        provider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) in
                            if let sharedURL = url as? URL {
                                print("Successfully extracted URL: \(sharedURL.absoluteString)")
                                self.putBackupedLink(sharedURL.absoluteString)
                                self.openMainApp(with: sharedURL)
                            }
                        }
                        break
                    }
                }
            }
        }
        
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    private func openMainApp(with url: URL) {
        let encodedURL = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let scheme = "yourgallery://shared?url=\(encodedURL)"
        
        guard let redirectURL = URL(string: scheme) else { return }

        print("Attempting to open main app with URL: \(redirectURL.absoluteString)")
        
        DispatchQueue.main.async {
            var responder: UIResponder? = self
            while let r = responder {
                if let app = r as? UIApplication {
                    app.perform(#selector(UIApplication.open(_:options:completionHandler:)), with: redirectURL, with: nil)
                    return
                }
                responder = r.next
            }
            print("Could not find a UIApplication instance to open the app.")
        }
    }
    
    private func putBackupedLink(_ url: String){
        if let ud = UserDefaults(suiteName: "group.com.YourGallery.share"){
            ud.setValue(url, forKey: "shared_url")
        }
    }

}
