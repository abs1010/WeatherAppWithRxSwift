//
//  APIService.swift
//  TheWeatherAppRxSwift
//
//  Created by Alan Silva on 03/12/20.
//

import UIKit
import RxSwift
import RxCocoa

struct Resource<T> {
    let url: URL
}

extension URLRequest {
    
    static func request<T: Decodable>(resource: Resource<T>) -> Observable<T> {
        
        return Observable.from([resource.url])
            .flatMap { url -> Observable<Data> in
                let request = URLRequest(url: url)
                return URLSession.shared.rx.data(request: request)
        }.map { data -> T in
            return try JSONDecoder().decode(T.self, from: data)
        }.asObservable()
        
    }
    
}

extension URL {
    
    static func urlForWeather(_ city: String) -> URL? {
        
        return URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&APPID=d909fb10b54074b50c128e3cbead106e&units=imperial")
        
    }
    
}
