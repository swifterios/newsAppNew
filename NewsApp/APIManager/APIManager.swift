//
//  APIManager.swift
//  NewsApp
//
//  Created by Владислав on 04.08.2021.
//

import Foundation

final class APIManager {
    
    static let shared = APIManager()
    
    struct Constants {
        static let apiPath = "/v2/everything"
        static let host = "newsapi.org"
        static let apiKey = "1084ffff938444e0bc3f5b228ab10037"
        static let sources = "cnn"
    }
    
    //MARK: - Enums

    enum APIError: Error {
        case failedToGetNews
    }
    
    //MARK: - API funcs
    
    
    // Get news by day
    public func getLastNewsByDay(day: Int,
                                 completion: @escaping (Result<NewsModel, Error>) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Constants.host
        urlComponents.path = Constants.apiPath
        
        let currentDate = Date()
        let secondsInDay = 24 * 3600
        let minusSecs = day * -secondsInDay
        
        let countedCurrentDate = currentDate.addingTimeInterval(TimeInterval(day * minusSecs))
        let pastDayCounted = currentDate.addingTimeInterval(TimeInterval((day - 1) * minusSecs))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY-MM-dd'T'HH:mm" // 2021-08-04T14:06
        let currentDateFormatted = dateFormatter.string(from: countedCurrentDate)
        let pastDayFormatted = dateFormatter.string(from: pastDayCounted)
        
        urlComponents.queryItems = [URLQueryItem(name: "apiKey", value: Constants.apiKey),
                                    URLQueryItem(name: "from", value: pastDayFormatted),
                                    URLQueryItem(name: "to", value: currentDateFormatted),
                                    URLQueryItem(name: "sources", value: Constants.sources)]
        
        guard let url = urlComponents.url else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetNews))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(NewsModel.self, from: data)
                print(result)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
}
