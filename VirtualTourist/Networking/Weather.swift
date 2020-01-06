//
//  Weather.swift
//  VirtualTourist
//
//  Created by Naif on 27/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import Foundation

class WeatherClass {
    
    public func getLocationWeather(_ long: Double, _ lat: Double, completion: @escaping (Main?,String?, Error?) -> ())
    {
        let request = URLRequest(url: URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&APPID=580d36494cebdd4a4507267a4a0f812c")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, err in
            guard let data = data else {
                print(err!)
                completion(nil,nil,err)
                return
            }
            let result = try! JSONDecoder().decode(Welcome.self, from: data)
            completion(result.main,result.weather?.first?.icon,nil)
        }
        task.resume()
    }
    
//    struct Main: Codable {
//        let temp, feelsLike, tempMin, tempMax: Double
//        let pressure, humidity: Int
//
//        enum CodingKeys: String, CodingKey {
//            case temp
//            case feelsLike = "feels_like"
//            case tempMin = "temp_min"
//            case tempMax = "temp_max"
//            case pressure, humidity
//        }
//    }
}
