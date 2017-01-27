//
//  MovieDetailed.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 16-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import UIKit
import ObjectMapper
import GRDB


class MovieDetailed : MovieMDB{
    public var genres : Array<Genre>?
    public var cast : Array<Cast>?
    public var crew : Array<Crew>?
    public var seen = false
    
    public override func dictionaryRepresentation() -> NSDictionary {
        let dictionary = super.dictionaryRepresentation() as? NSMutableDictionary
        
        dictionary?.setValue(seen, forKey: "seen")
        dictionary?.setValue(createCastArrayofDictionarys(), forKey: "cast")
        dictionary?.setValue(createCrewArrayofDictionarys(), forKey: "crew")
        dictionary?.setValue(createGenresArrayofDictionarys(), forKey: "genres")

        return dictionary!
    }
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [MovieDetailed]
    {
        var models:[MovieDetailed] = []
        for item in array
        {
            models.append(MovieDetailed(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        super.init(dictionary: dictionary)
        if (dictionary["seen"]) != nil {
            seen = Bool((dictionary["seen"] as? NSNumber)!)
        }
        else {
            seen = false
        }
        if (dictionary["cast"] != nil) { cast = Cast.modelsFromDictionaryArray(array: dictionary["cast"] as! NSArray) }
        else {
            cast = Array<Cast>()
        }
        if (dictionary["crew"] != nil) { crew = Crew.modelsFromDictionaryArray(array: dictionary["crew"] as! NSArray) }
        else {
            crew = Array<Crew>()
        }
        if (dictionary["genres"] != nil) { genres = Genre.modelsFromDictionaryArray(array: dictionary["genres"] as! NSArray) }
        else {
            genres = Array<Genre>()
        }
    }
    
    required public init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
    
    required init(row: Row) {
        fatalError("init(row:) has not been implemented")
    }

    private func createCastArrayofDictionarys() -> Array<NSDictionary> {
        var array = Array<NSDictionary>()
        for person in self.cast! {
            array.append(person.dictionaryRepresentation())
        }
        return array
    }
    
    private func createCrewArrayofDictionarys() -> Array<NSDictionary> {
        var array = Array<NSDictionary>()
        for person in self.crew! {
            array.append(person.dictionaryRepresentation())
        }
        return array
    }
    
    private func createGenresArrayofDictionarys() -> Array<NSDictionary> {
        var array = Array<NSDictionary>()
        for genre in self.genres! {
            array.append(genre.dictionaryRepresentation())
        }

        return array
    }

}
