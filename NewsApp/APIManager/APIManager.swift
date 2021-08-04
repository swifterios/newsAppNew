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
        static let apiURL = "https://newsapi.org/v2/top-headlines"
        static let apiKey = "1084ffff938444e0bc3f5b228ab10037"
    }
    
    //MARK: - Enums

    enum APIError: Error {
        case failedToGetNews
    }
    
    private func getNewsByPage(page: Int, completion: @escaping (Result<NewsModel, Error>) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.path = Constants.apiURL
        urlComponents.queryItems = [URLQueryItem(name: "apiKey", value: Constants.apiKey),
                                    URLQueryItem(name: "page", value: String(page)),
                                    URLQueryItem(name: "country", value: "ru")]
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
