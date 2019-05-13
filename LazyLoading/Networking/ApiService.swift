//
//  ApiService.swift
//  LazyLoading
//
//  Created by Amit on 5/11/19.
//  Copyright © 2019 Amit. All rights reserved.
//

import Foundation

class ApiService {
    typealias JSONDictionary = [String: Any]
    typealias QueryResult = ([ListItem]?, String) -> Void

    let defaultSession = URLSession(configuration: .default)

    var dataTask: URLSessionDataTask?
    var list: [ListItem] = []
    var errorMessage = ""

    func getResults(limit: Int, completion: @escaping QueryResult) {
        dataTask?.cancel()

        if var urlComponents = URLComponents(string: "http://devaddons1.socialengineaddons.com/mobiledemodevelopment/api/rest/albums") {
            urlComponents.query = "page=1&limit=\(limit)&oauth_consumer_key=nt416zygfd0o6h2gabjv2qy4nj0wcdyo&ios=1&language=en&oauth_consumer_secret=f2ax3r6yzki9yiiby7g0v4rlbnl16dio&_IOS_VERSION=2.1.6"

            guard let url = urlComponents.url else { return }

            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }

                if let error = error {
                    self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    self.parseResult(data)

                    DispatchQueue.main.async {
                        completion(self.list, self.errorMessage)
                    }
                }
            }

            dataTask?.resume()
        }
    }

    fileprivate func parseResult(_ data: Data) {
        var response: JSONDictionary?

        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }

        guard let dict = response!["body"] as? [String: Any] else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }

        guard let array = dict["response"] as? [Any] else {
            errorMessage += "not an array structure\n"
            return
        }
        var index: Int = 0
        for listDictionary in array {
            if let listDictionary = listDictionary as? JSONDictionary,
                let imageUrl = listDictionary["image"] as? String,
                let title = listDictionary["title"] as? String {
                list.append(ListItem(title: title, imageUrl: imageUrl, indexValue: index))

            } else {
                errorMessage += "Problem parsing dictionary\n"
            }
            index += 1
        }
    }
}
