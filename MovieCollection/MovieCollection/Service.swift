//
//  Service.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 17-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

enum requestID : Int{
    case GENRES, SEARCHMOVIE, SEARCHACTOR, GETCREDITS, SEARCHPERSON, VIDEOURL
}

protocol serviceDataReceiver {
    func dataReceivedFromService(data : Any, id : requestID)
}

struct URLS {
    public static let SCHEME = "https://"
    public static let HOST = "api.themoviedb.org/3"
    public static let API_KEY = "e663ec317cdcc0e476af5ee28c0cdf0c"
    public static let IMAGE_URL = "https://image.tmdb.org/t/p/w500/"
    public static let BASE_URL = "https://api.themoviedb.org/3"
    public static let GENRE_APPEND_URL = "/genre/movie/list?api_key=\(API_KEY)&language=en-US"
    public static let MOVIE_SEARCH_APPEND_URL = "/search/movie?api_key=\(API_KEY)&language=en-US&query=<<QUERY>>&page=1"
    public static let CREDITS_SEARCH_APPEND_URL = "/movie/<<MOVIEID>>/credits?api_key=\(API_KEY)"
    public static let PERSON_SEARCH_APPEND_URL = "/search/person?api_key=\(API_KEY)&language=en-US&query=<<QUERY>>&page=1&include_adult=false"
    public static let TRAILER_SEARCH_APPEND_URL = "/movie/<<MOVIEID>>/videos?api_key=\(API_KEY)&language=en-US"
}

class Service {
    public var delegate : serviceDataReceiver?

    
    public func getGenres(){
        let url =  URLS.BASE_URL.appending(URLS.GENRE_APPEND_URL)
        Alamofire.request(url).responseObject { (response: DataResponse<GenresAPIResponse>) in
            
            switch response.result {
            case .success(let genres):
                debugPrint("success")
                
                self.delegate?.dataReceivedFromService(data: genres.genres!, id: .GENRES)
                
                break;
            case .failure(let error):
                print("Error occured : \(error.localizedDescription)")
                break;
            }
            
        }
    }
    
    public func searchMovie(query: String) {
        
        let url =  URLS.BASE_URL.appending(URLS.MOVIE_SEARCH_APPEND_URL).replacingOccurrences(of: "<<QUERY>>", with: query.replacingOccurrences(of: " ", with: "+"))
        Alamofire.request(url).responseObject { (response: DataResponse<MovieAPIResponse>)  in
            
            switch response.result {
            case .success(let movies):
                print("And all was well")
                
                if movies.results != nil, (movies.results?.count)! > 0 {
                    self.delegate?.dataReceivedFromService(data: movies.results!, id: .SEARCHMOVIE)
                }
                break
            case .failure(let error):
                print("Error occured : \(error.localizedDescription)")
                break
            }
            
        }
    }
    
    public func searchPerson(query: String) {
        let url =  URLS.BASE_URL.appending(URLS.PERSON_SEARCH_APPEND_URL).replacingOccurrences(of: "<<QUERY>>", with: query.replacingOccurrences(of: " ", with: "+"))
        Alamofire.request(url).responseObject { (response: DataResponse<PersonAPIResponse>)  in
            
            switch response.result {
            case .success(let persons):

                if persons.results != nil, (persons.results?.count)! > 0 {
                    self.delegate?.dataReceivedFromService(data: persons.results!, id: .SEARCHPERSON)
                }
                break
            case .failure(let error):
                print("Error occured : \(error.localizedDescription)")
                break
            }
//            }.responseString { response in
//                print("Success: \(response.result.isSuccess)")
//                                print("Response String: \(response.result.value)")
        }
    }
    
    public func getVideo(id: Int) {
        let url =  URLS.BASE_URL.appending(URLS.TRAILER_SEARCH_APPEND_URL).replacingOccurrences(of: "<<MOVIEID>>", with: String(id))
        Alamofire.request(url).responseObject { (response: DataResponse<VideosAPIResponse>)  in
            
            switch response.result {
            case .success(let videos):
                if videos.results != nil, (videos.results?.count)! > 0 {
                    self.delegate?.dataReceivedFromService(data: (videos.results?[0])!, id: .VIDEOURL)
                }
                break
                
            case .failure(let error):
                print("Error occured : \(error.localizedDescription)")
                break
            }
            
        }
    }
    
    public func getCredits(id: Int) {
        let url =  URLS.BASE_URL.appending(URLS.CREDITS_SEARCH_APPEND_URL).replacingOccurrences(of: "<<MOVIEID>>", with: String(id))
        Alamofire.request(url).responseObject { (response: DataResponse<CreditsAPIResponse>)  in
            
            switch response.result {
            case .success(let credits):
                
                self.delegate?.dataReceivedFromService(data: credits, id: .GETCREDITS)
                break
            case .failure(let error):
                print("Error occured : \(error.localizedDescription)")
                break
            }
            
        }
    }
    
    
}
