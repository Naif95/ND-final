//
//  HelperFunctions.swift
//  VirtualTourist
//
//  Created by Naif on 23/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import Foundation
import UIKit

struct displayAlert {
    
    static func displayAlert(message: String, title: String, vc: UIViewController, shouldReturn: Bool)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var OKAction = UIAlertAction(title: "ok", style: .default, handler: nil)
        if (shouldReturn)
        {
            OKAction = UIAlertAction(title: "ok", style: .default, handler: { (alertOKAction) in
                vc.navigationController!.popToRootViewController(animated: true)
            })
        }
        alertController.addAction(OKAction)
        vc.present(alertController, animated: true, completion: nil)
    }
}

func LoadingActivityIndicator<T:UIView>(_ loadingIn: Bool,view: T,collectionView: UICollectionView?,tag: Int)  {
    if(loadingIn){
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = view.center
        activityIndicator.color = .gray
        activityIndicator.frame = view.frame
        activityIndicator.contentMode = UIView.ContentMode.scaleAspectFit
        activityIndicator.tag = tag
        activityIndicator.startAnimating()
        if(collectionView == nil){
            view.addSubview(activityIndicator)
        }else{
            collectionView!.backgroundView = activityIndicator
        }
    }else{
        if(collectionView == nil){
            view.viewWithTag(tag)?.removeFromSuperview()
        }else{
            collectionView?.backgroundView = nil
        }
    }
}
