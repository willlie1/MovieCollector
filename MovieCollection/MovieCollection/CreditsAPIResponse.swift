//
//  CreditsAPIResponse.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 18-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class CreditsAPIResponse : Mappable {
    public var id: Int?
    public var crew: Array<Crew>?
    public var cast: Array<Cast>?
    
    required public init?(map:Map){
        
    }
    
    public func mapping(map:Map){
        self.id <- map["id"]
        self.cast <- map["cast"]
        self.crew <- map["crew"]
    }
}
