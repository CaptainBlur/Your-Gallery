//
//  SceneDelegate+Extension.swift
//  iosApp
//
//  Created by Valdo on 02.03.2025.
//
import Foundation

extension SceneDelegate{
    func extractBackupedShareUrl()-> String?{
        if let ud = UserDefaults(suiteName: "group.com.YourGallery.share") {
            let result = ud.string(forKey: "shared_url")
            ud.removeObject(forKey: "shared_url")
            return result
        } else {
            return nil
        }
    }
    func removeBackupedShareUrl(){
        if let ud = UserDefaults(suiteName: "group.com.YourGallery.share") {
            ud.removeObject(forKey: "shared_url")
        }
    }
}
