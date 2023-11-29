//
//  BibleStudyService.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/28/23.
//

import Foundation

protocol NetworkRequestable {
    func makeRequest(with url: URL, headers: [String: String], completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}


class NetworkService: NetworkRequestable {
    func makeRequest(with url: URL, headers: [String: String], completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: completion)
        dataTask.resume()
    }
}


class BibleReadingPlanAPIClient {
    private let networkService: NetworkRequestable

    init(networkService: NetworkRequestable) {
        self.networkService = networkService
    }

    func fetchBibleReadingPlan(completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let headers = [
            "X-RapidAPI-Key": APP.Product.rapidAPIKey,
            "X-RapidAPI-Host": "iq-bible.p.rapidapi.com"
        ]
        guard let url = URL(string: "https://iq-bible.p.rapidapi.com/GetBibleReadingPlan?days=365"
                           /* &requestedStartDate=2023-01-01&requestedAge=15*/) else {
            completion(nil, nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        networkService.makeRequest(with: url, headers: headers, completion: completion)
    }
}

// Usage

