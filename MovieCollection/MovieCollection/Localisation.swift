//
//  Localisation.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 22-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import Foundation

class Localisation {
    
    public static func getDateFormattedToLocale(dateAsString: String) -> String{
        //var f = NSDate()
        let f = getLocaleDateFormatter()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let fd = dateFormatter.date(from: dateAsString)
        
        return f.string(from:fd!)
    }
    
    public static func getLocaleDateFormatter() -> DateFormatter {
        let f = DateFormatter()
        let locale = NSLocale(localeIdentifier: NSLocale.current.identifier)
        let format = DateFormatter.dateFormat(fromTemplate: "YYYY-MM-dd", options: 0, locale: locale as Locale) ?? "n/a"
        f.dateFormat = format
        f.locale = locale as Locale!
        
        return f
    }
}
