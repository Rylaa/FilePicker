//
//  PreviewTitleBuilder.swift
//  
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//
//

import UIKit
import Photos
import CoreLocation

class PreviewTitleBuilder {
    
    static func titleFor(asset: PHAsset,using theme:Settings.Theme, completion: @escaping (NSAttributedString) -> Void) {
        if let location = asset.location {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let locality = placemarks?.first?.locality {
                    let mutableAttributedString = NSMutableAttributedString()
                    mutableAttributedString.append(NSAttributedString(string: locality, attributes: theme.previewTitleAttributes))
                    
                    if let created = asset.creationDate {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .long
                        formatter.timeStyle = .short
                        let dateString = "\n" + formatter.string(from: created)
                        
                        mutableAttributedString.append(NSAttributedString(string: dateString, attributes: theme.previewSubtitleAttributes))
                    }
                    
                    completion(mutableAttributedString)
                } else if let created = asset.creationDate {
                    completion(titleFor(date: created, using: theme))
                }
            }
        } else if let created = asset.creationDate {
            completion(titleFor(date: created, using: theme))
        }
    }
    
    private static func titleFor(date: Date,using theme:Settings.Theme) -> NSAttributedString {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .long
        
        let text = NSMutableAttributedString()
        
        text.append(NSAttributedString(string: dateFormatter.string(from: date), attributes: theme.previewTitleAttributes))
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        text.append(NSAttributedString(string: "\n" + dateFormatter.string(from: date), attributes: theme.previewSubtitleAttributes))
        
        return text
    }
}
