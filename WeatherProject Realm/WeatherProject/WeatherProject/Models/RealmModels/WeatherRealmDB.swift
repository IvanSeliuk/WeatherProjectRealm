//
//  WeatherRealmDB.swift
//  WeatherProject
//
//  Created by Иван Селюк on 26.05.22.
//

import RealmSwift

class WeatherRealmDB: Object {
    @Persisted var id: String = UUID().uuidString
    @Persisted var country: String
    @Persisted var date: Date?
    @Persisted var feelsLike: Double
    @Persisted var humidity: Int
    @Persisted var icon: String?
    @Persisted var lat: Double
    @Persisted var lon: Double
    @Persisted var name: String
    @Persisted var pressure: Int
    @Persisted var source: String
    @Persisted var temp: Double
    @Persisted var tempMax: Double
    @Persisted var tempMin: Double
    @Persisted var visibility: Int
    @Persisted var windSpeed: Double
    
    convenience init(weather: Welcome, date: Date, source: SourceValue.RawValue) {
        self.init()
        
        self.country = weather.sys.country
        self.feelsLike = weather.main.feelsLike
        self.humidity = weather.main.humidity
        self.icon = weather.weather.first?.icon
        self.lat = weather.coord.lat
        self.lon = weather.coord.lon
        self.name = weather.name
        self.pressure = weather.main.pressure
        self.source = source
        self.temp = weather.main.temp
        self.tempMax = weather.main.tempMax
        self.tempMin = weather.main.tempMin
        self.visibility = weather.visibility
        self.windSpeed = weather.wind.speed
        self.date = date
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func getMappedWeather() -> WeatherDate {
        return (Welcome(coord: Coord(lon: lon, lat: lat),
                       weather: [Weather(main: "", weatherDescription: "", icon: icon ?? "")],
                       main: Main(temp: temp,
                                  feelsLike: feelsLike,
                                  tempMin: tempMin,
                                  tempMax: tempMax,
                                  pressure: Int(pressure),
                                  humidity: Int(humidity)),
                       visibility: Int(visibility),
                       wind: Wind(speed: windSpeed),
                        sys: Sys(country: country),
                        name: name),
                getMappedData())
    }
    
    func getMappedData() -> Date {
        return date ?? Date()
    }
}
