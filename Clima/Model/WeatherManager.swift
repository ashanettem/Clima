//
//  WeatherManager.swift
//  Clima
//
//  Created by PandaH on 11/16/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather:WeatherModel)
    func didFailWithError(_ weatherManager: WeatherManager, error:Error)
}


struct WeatherManager{
    let url = "https://api.openweathermap.org/data/2.5/weather?appid=58e21d10aa1ac438f89d2bddeaff6b59&units=imperial"
    
    var delegate:WeatherManagerDelegate?
    
    func fetchWeather(cityName:String){
        let urlString = "\(url)&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(url)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String){
        //1. create URL
        // use if let to prevent url from failing if link info is bad or is nil
        if let url = URL(string: urlString){
            
            //2. create url session
            let session = URLSession(configuration: .default)
            
            //3. give session a task
            let task = session.dataTask(with: url) {(data, response, error) in
                if error != nil{
                    delegate?.didFailWithError(self, error: error!)
                    print(error!)
                }
            
                if let safeData = data{
                    if let weather = parseJSON(weatherData: safeData){
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            //4. start the task
            task.resume()
        }
    }
    
    func parseJSON(weatherData:Data)->WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            let name = decodedData.name
            let temp = decodedData.main.temp
            //print(decodedData.weather[0].description)
            let id = decodedData.weather[0].id
            
            let weather = WeatherModel(conditionID: id, cityName: name, temperature: temp)
            
            return weather
        }
        catch{
            delegate?.didFailWithError(self, error: error)
            return nil
        }
        
    }
    
}
