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
    
    override func didSelectPost() {
        print("🟢 didSelectPost() triggered")

        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            print("🟡 Found NSExtensionItem: \(item)")

            if let attachments = item.attachments {
                for provider in attachments {
                    print("🔵 Checking provider: \(provider)")

                    if provider.hasItemConformingToTypeIdentifier("public.url") {
                        print("🟣 Found public.url type")

                        provider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) in
                            if let sharedURL = url as? URL {
                                print("✅ Successfully extracted URL: \(sharedURL.absoluteString)")
//                                let result = self.openUrl(sharedURL)
//                                print("✅ Attempted to force open the main app: \(result)")
                                self.openMainApp(with: sharedURL)
                            } else {
                                print("❌ Failed to extract URL, error: \(String(describing: error))")
                            }
                        }
                        break
                    }
                }
            } else {
                print("🔴 No attachments found!")
            }
        } else {
            print("❌ No NSExtensionItem found!")
        }

        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }


    
    private func openMainApp(with url: URL) {
        let encodedURL = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let scheme = "yourgallery://shared?url=\(encodedURL)"
        
        guard let redirectURL = URL(string: scheme) else {
            print("❌ Failed to create valid redirect URL")
            return
        }

        print("🚀 Attempting to open main app with URL: \(redirectURL.absoluteString)")

        // Try using UIApplication directly (hidden API workaround)
        DispatchQueue.main.async {
            var responder: UIResponder? = self
            while let r = responder {
                if let app = r as? UIApplication {
                    app.perform(#selector(UIApplication.open(_:options:completionHandler:)), with: redirectURL, with: nil)
                    print("✅ Attempted to force open the main app.")
                    return
                }
                responder = r.next
            }
            print("❌ Could not find a UIApplication instance to open the app.")
        }
    }

//    @objc @discardableResult func openUrl(_ url: URL)-> Bool {
//        var responder: UIResponder? = self
//        while responder != nil {
//            if let application = responder as? UIApplication {
//                return application.perform(#selector(openUrl(_:)), with: url) != nil
//            }
//            responder = responder?.next
//            }
//        return false
//    }


}
