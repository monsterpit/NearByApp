//
//  UIApplication+KeyWindow.swift
//  NearByApp
//
//  Created by Vikas Salian on 17/12/23.
//

import UIKit

extension UIApplication {
    
    var keyWindow: UIWindow? {
        if #available(iOS 13.0, *){
            return (connectedScenes.first?.delegate as? SceneDelegate)?.window
        }else{
            return windows.first
        }
    }
    
}
