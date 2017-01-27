//
//  MovieCollectorDatabase.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 16-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import Foundation
import GRDB

class MovieCollectorDatabase {

    public var dbQueue : DatabaseQueue?
    
    init() {
//        debugPrint("initialize database")
        do {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
            let databasePath = documentsPath.appendingPathComponent("db.sqlite")
            dbQueue = try DatabaseQueue(path: databasePath)
        }
        catch let error as NSError{
            print("creating databaseQueue went wrong: \(error)")
        }
        createDatabase()
        
    }
    
    func bulkInsertGenres(genreDictionarys : Array<NSDictionary>) {
        do{
            try dbQueue?.inDatabase { db in
//                try db.execute("DELETE FROM genres")
                
                for genre in genreDictionarys {
                    try db.execute("INSERT OR REPLACE into genres (name, id) values ('\(genre["name"]!)', \(genre["id"]!))")
                }
            }
        }
        catch let error as NSError {
            print("failed to insert genres: \(error)")
        }
    }
    
    func setMovieSeenValue(seenValue: Bool, movieId: Int) {
        do{
            try dbQueue?.inDatabase { db in
                let seen = seenValue ? 1 : 0
                try db.execute("UPDATE movies SET seen = \(seen) WHERE id = \(movieId)")
            }
        }
        catch let error as NSError {
            print("failed to seen value: \(error)")
        }

    }
    
    func insertMovie(movie : NSDictionary){
        if movie["genres"] == nil {
            print("insert a movieDetailed class as dictionary")
            return
        }
        do{
            try dbQueue?.inDatabase { db in
                let overview = (movie["overview"] as! String).replacingOccurrences(of: "'", with: "''")
                let title = (movie["title"] as! String).replacingOccurrences(of: "'", with: "''")
                let original = (movie["original_title"] as! String).replacingOccurrences(of: "'", with: "''")
                var backdropPath = movie["backdrop_path"] as? String
                if backdropPath == nil {
                    backdropPath = ""
                }
                try db.execute("INSERT OR REPLACE into movies (title, poster_path, overview, release_date, id, original_title, original_language, release_date, backdrop_path, popularity, vote_count, vote_average, seen) values ('\(title)', '\(movie["poster_path"] as! String)', '\(overview)', '\(movie["release_date"] as! String)', \(movie["id"] as! Int), '\(original)', '\(movie["original_language"] as! String)', '\(movie["release_date"] as! String)', '\(backdropPath)', \(movie["popularity"] as! Double), \(movie["vote_count"] as! Int), \(movie["vote_average"] as! Double), \(movie["seen"]!))")
                
//                debugPrint("insert genres")
                if let genres = movie["genres"] as? Array<NSDictionary> {
                    for genre in genres  {
                        try db.execute("INSERT OR REPLACE into moviegenres (movieID, genreID) values (\(movie["id"]!), \(genre["id"]!))")
                    }
                }
//                debugPrint("insert crew")
                if let crewPersons = movie["crew"] as? Array<NSDictionary> {
                    for crewPerson in crewPersons  {
                        let name = (crewPerson["name"] as! String).replacingOccurrences(of: "'", with: "''")
                        try db.execute("INSERT OR REPLACE into crew (name, id, job, profile_path, department, credit_id) values ('\(name)', \(crewPerson["id"]!), '\(crewPerson["job"]!)', '\(crewPerson["profile_path"]!)', '\(crewPerson["department"]!)', '\(crewPerson["credit_id"]!)')")
                        try db.execute("INSERT OR REPLACE into movieCrew (movieID, personID) values (\(movie["id"]!), \(crewPerson["id"]!))")
                    }
                }
//                debugPrint("insert cast")
                if let castPersons = movie["cast"] as? Array<NSDictionary> {
                    for castPerson in castPersons  {
                        let name = (castPerson["name"] as! String).replacingOccurrences(of: "'", with: "''")
                        let character = (castPerson["character"] as! String).replacingOccurrences(of: "'", with: "''")
                        try db.execute("INSERT OR REPLACE into cast (name, id, cast_id, profile_path, character, credit_id, 'order') values ('\(name)', \(castPerson["id"]!), \(castPerson["cast_id"]!), '\(castPerson["profile_path"]!)', '\(character)', '\(castPerson["credit_id"]!)', \(castPerson["order"]!))")
                        try db.execute("INSERT OR REPLACE into movieCast (movieID, personID) values (\(movie["id"]!), \(castPerson["id"]!))")
                    }
                }
            }
        }
        catch let error as NSError{
            print("failed to insert movie: \(error)")
        }
    }
    
    public func getMovies(searchTitle: String?) -> Array<NSDictionary> {
        var arrayOfMovies = Array<NSDictionary>()
        
        var query = "SELECT * FROM movies"
        if searchTitle != nil {
            query = "SELECT * FROM movies WHERE title LIKE '%\(searchTitle!)%'"
            query = query.replacingOccurrences(of: "\'", with: "'")
        }
        do{
            try dbQueue?.inDatabase { db in
                let rows = try Row.fetchAll(db, query)
                for row in rows {
                    let dictionary = NSMutableDictionary()
                    for (name, _) in row {
                        if name == "vote_count" || name == "seen" || name == "id" {
                            let int = row.value(named: name) as? Int64
                            dictionary.setValue(Int(truncatingBitPattern: int!), forKey: name)
                        }
                        else {
                            let rowValue = row.value(named: name)
                            dictionary.setValue(rowValue!, forKey: name)
                        }
                        
                        if name == "id" {
                            dictionary.setValue(getCast(movieID: row.value(named: name), db: db), forKey: "cast")
                            dictionary.setValue(getCrew(movieID: row.value(named: name), db: db), forKey: "crew")
                            dictionary.setValue(getGenres(movieID: row.value(named: name), db: db), forKey: "genres")
                        }
                    }
                     arrayOfMovies.append(dictionary)
                }
            }
        }
        catch let error as NSError {
            print("failed to retrieve movies: \(error)")
        }
        return arrayOfMovies
    }
    
    public func getGenres() -> Array<NSDictionary>{
        var arrayOfGenres = Array<NSDictionary>()
        do{
            try dbQueue?.inDatabase { db in
                let rows = try Row.fetchAll(db, "SELECT id, name FROM genres")
                for row in rows {
                    let dictionary = NSMutableDictionary()
                    let id = row.value(named: "id") as? Int64
                    
                    dictionary.setValue(Int(truncatingBitPattern: id!), forKey: "id")
                    dictionary.setValue(row.value(named: "name"), forKey: "name")
                    arrayOfGenres.append(dictionary)
                }
            }
        }
        catch let error as NSError {
            print("failed to retrieve genres: \(error)")
        }
        return arrayOfGenres
    }
    
    private func createWhereClause(ids : Array<Int>) -> String{
        if ids.count > 0 {
            var whereClause = "WHERE "
            var idCount = 0
            for id in ids {
                whereClause = whereClause.appending("id = \(id)")
                if idCount < ids.count - 1{
                    whereClause = whereClause.appending(" OR ")
                }
                idCount += 1
            }
            return whereClause
        }
        else {
            return ""
        }
    }
    
    public func getGenresByIds(ids : Array<Int>) -> Array<NSDictionary>{
        var arrayOfGenres = Array<NSDictionary>()
        
        do{
            try dbQueue?.inDatabase { db in
                let rows = try Row.fetchAll(db, "SELECT id, name FROM genres \(createWhereClause(ids: ids))")
                for row in rows {
                    let dictionary = NSMutableDictionary()
                    let id = row.value(named: "id") as? Int64
                    dictionary.setValue(Int(truncatingBitPattern: id!), forKey: "id")
                    dictionary.setValue(row.value(named: "name"), forKey: "name")
                    arrayOfGenres.append(dictionary)
                }
            }
        }
        catch let error as NSError {
            print("failed to retrieve genres: \(error)")
        }
        return arrayOfGenres
    }
    
    private func getGenres(movieID : Int, db: Database) ->  Array<NSDictionary>{
        var arrayOfGenres = Array<NSDictionary>()
        do{
            let rows = try Row.fetchAll(db, "SELECT *  FROM movieGenres WHERE movieID = \(movieID)")
            for row in rows {
                let dictionary = NSMutableDictionary()
                let personID = Int(truncatingBitPattern:(row.value(named: "genreID") as? Int64)!)
                
                let personRows = try Row.fetchAll(db, "SELECT *  FROM genres WHERE id = \(personID)")
                
                for personRow in personRows {
                    for (name, value) in personRow {
//                        debugPrint("value: \(value)")
                        if name == "id" {
                            let int = value.value() as? Int64
                            dictionary.setValue(Int(truncatingBitPattern: int!), forKey: name)
                        }
                        else {
                            dictionary.setValue(value.value()!, forKey: name)
                        }
                    }
                    
                }
                arrayOfGenres.append(dictionary)
            }
        
        }
        catch let error as NSError {
            print("failed to retrieve genres: \(error)")
        }
        return arrayOfGenres
    }
    
    private func getCrew(movieID : Int, db: Database) ->  Array<NSDictionary>{
        var arrayOfCrew = Array<NSDictionary>()
        do{
            let rows = try Row.fetchAll(db, "SELECT *  FROM movieCrew WHERE movieID = \(movieID)")
            for row in rows {
                let dictionary = NSMutableDictionary()
                let personID = Int(truncatingBitPattern:(row.value(named: "personID") as? Int64)!)
                
                let personRows = try Row.fetchAll(db, "SELECT *  FROM crew WHERE id = \(personID)")
                
                for personRow in personRows {
                    for (name, value) in personRow {
//                        debugPrint("value: \(value)")
                        if name == "id" {
                            let int = value.value() as? Int64
                            dictionary.setValue(Int(truncatingBitPattern: int!), forKey: name)
                        }
                        else {
                            dictionary.setValue(value.value()!, forKey: name)
                        }
                    }

                }
                arrayOfCrew.append(dictionary)
            }
            
        }
        catch let error as NSError {
            print("failed to retrieve crew: \(error)")
        }
        return arrayOfCrew
    }
        
    
    private func getCast(movieID : Int, db: Database) -> Array<NSDictionary>{
        var arrayOfCast = Array<NSDictionary>()
        do{
            let rows = try Row.fetchAll(db, "SELECT *  FROM movieCast WHERE movieID = \(movieID)")
            for row in rows {
                let dictionary = NSMutableDictionary()
                let personID = Int(truncatingBitPattern:(row.value(named: "personID") as? Int64)!)
                
                let personRows = try Row.fetchAll(db, "SELECT *  FROM cast WHERE id = \(personID)")
                
                for personRow in personRows {
                    for (name, value) in personRow {
//                        debugPrint("value: \(value)")
                        if name == "id" {
                            let int = value.value() as? Int64
                            dictionary.setValue(Int(truncatingBitPattern: int!), forKey: name)
                        }
                        else {
                            dictionary.setValue(value.value()!, forKey: name)
                        }
                    }
                    
                }
                arrayOfCast.append(dictionary)
            }
            
        }
        catch let error as NSError {
            print("failed to retrieve Cast: \(error)")
        }
        return arrayOfCast
    }
    
    private func createDatabase() {
//        debugPrint("creating database")
        do {
            try dbQueue?.inDatabase { db in
                try db.execute(
                    "CREATE TABLE IF NOT EXISTS movies (" +
                        "title TEXT NOT NULL, " +
                        "poster_path TEXT NOT NULL, " +
                        "overview TEXT NOT NULL, " +
                        "release_date TEXT NOT NULL," +
                        "id INTEGER NOT NULL PRIMARY KEY," +
                        "original_title TEXT NOT NULL," +
                        "original_language TEXT NOT NULL," +
                        "backdrop_path TEXT NOT NULL," +
                        "popularity REAL NOT NULL," +
                        "vote_count INTEGER NOT NULL," +
                        "vote_average REAL NOT NULL," +
                        "seen BOOLEAN NOT NULL" +
                    ")")
            }
        } catch let error as NSError  {
            print("could not create the movies table: \(error)")
        }

        do {
            try dbQueue?.inDatabase { db in
                try db.execute(
                    "CREATE TABLE IF NOT EXISTS cast (" +
                        "name TEXT NOT NULL, " +
                        "id INTEGER NOT NULL PRIMARY KEY," +
                        "cast_id INTEGER NOT NULL," +
                        "profile_path TEXT NOT NULL," +
                        "character TEXT NOT NULL," +
                        "'order' INTEGER NOT NULL," +
                        "credit_id TEXT NOT NULL" +
                    ")")
            }
        } catch let error as NSError  {
            print("could not create the cast table: \(error)")
        }

        do {
            try dbQueue?.inDatabase { db in
                try db.execute(
                    "CREATE TABLE IF NOT EXISTS crew (" +
                        "name TEXT NOT NULL, " +
                        "id INTEGER NOT NULL PRIMARY KEY," +
                        "profile_path TEXT NOT NULL," +
                        "department TEXT NOT NULL," +
                        "job TEXT NOT NULL," +
                        "credit_id TEXT NOT NULL" +
                    ")")
            }
        } catch let error as NSError  {
            print("could not create the persons table: \(error)")
        }
        do {
            try dbQueue?.inDatabase { db in
                try db.execute(
                    "CREATE TABLE IF NOT EXISTS genres (" +
                        "name TEXT NOT NULL, " +
                        "id INTEGER NOT NULL PRIMARY KEY" +
                    ")")
            }
        } catch let error as NSError  {
            print("could not create the genres table: \(error)")
        }
        
        do {
            try dbQueue?.inDatabase { db in
                try db.execute(
                    "CREATE TABLE IF NOT EXISTS movieGenres (" +
                        "movieID INTEGER, " +
                        "genreID INTEGER, " +
                        "PRIMARY KEY(movieID, genreID), " +
                        "FOREIGN KEY(movieID) REFERENCES movies(id)," +
                        "FOREIGN KEY(genreID) REFERENCES genres(id)" +
                    ")")
            }
        } catch let error as NSError  {
            print("could not create the movieGenres table: \(error)")
        }
        
        do {
            try dbQueue?.inDatabase { db in
                try db.execute(
                    "CREATE TABLE IF NOT EXISTS movieCrew (" +
                        "movieID INTEGER, " +
                        "personID INTEGER, " +
                        "PRIMARY KEY (movieID, personID), " +
                        "FOREIGN KEY(movieID) REFERENCES movies(id)," +
                        "FOREIGN KEY(personID) REFERENCES crew(id)" +
                    ")")
            }
        } catch let error as NSError  {
            print("could not create the movieCrew table: \(error)")
        }
        
        do {
            try dbQueue?.inDatabase { db in
                try db.execute(
                    "CREATE TABLE IF NOT EXISTS movieCast (" +
                        "movieID INTEGER, " +
                        "personID INTEGER, " +
                        "PRIMARY KEY (movieID, personID), " +
                        "FOREIGN KEY(movieID) REFERENCES movies(id)," +
                        "FOREIGN KEY(personID) REFERENCES cast(id)" +
                    ")")
            }
        } catch let error as NSError  {
            print("could not create the movieCast table: \(error)")
        }
    }
    
}
