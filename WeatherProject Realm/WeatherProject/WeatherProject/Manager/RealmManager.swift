//
//  RealmManager.swift
//  WeatherProject
//
//  Created by Иван Селюк on 26.05.22.
//

import RealmSwift
typealias WeatherDate = (welcome: Welcome, date: Date)

class RealmManager {
    enum RealmCodesError: Int {
        case changePrimaryKey = 1
        case migration = 10
    }
    
    static let shared = RealmManager()
    private let dataBaseName = "default.realm"
    private var version: UInt64 {
        set { UserDefaults.standard.set(newValue, forKey: "versionRealm") }
        get { return UInt64((UserDefaults.standard.object(forKey: "versionRealm") as? Int) ?? 1) }
    }
    
    private var dataBasePath: URL {
        return FileServiceManager.shared.documentDirectory.appendingPathComponent(self.dataBaseName)
    }
    
    private lazy var realm: Realm = {
        do {
            return try initRealm()
        } catch(let e) {
            guard let error = RealmCodesError(rawValue: (e as NSError).code) else { return try! initRealm() }
            switch error {
            case .migration: version += 1
            case .changePrimaryKey:
                version = 1
                try! FileManager.default.removeItem(at: dataBasePath)
            }
            return try! initRealm()
        }
    }()
    
    func initRealm() throws -> Realm {
        let config = Realm.Configuration(schemaVersion: version)
        Realm.Configuration.defaultConfiguration = config
        let _realm = try Realm()
        return _realm
    }
    
    func addWeatherToRealmBD(by weather: Welcome, source: SourceValue.RawValue, date: Date) {
        let WeatherRealmDB = WeatherRealmDB(weather: weather, date: date, source: source )
        print(FileServiceManager.shared.documentDirectory.appendingPathComponent(self.dataBaseName))
        do {
            try self.realm.write({
                self.realm.add(WeatherRealmDB, update: .modified)
                print("added")
            })
        } catch(let e) {
            print(e.localizedDescription)
        }
    }
    
    func getWeatherWithRealmBD(by source: String) -> [WeatherDate] {
        return realm.objects(WeatherRealmDB.self).filter("source == %@", source).sorted(by: \.date, ascending: false).map { $0.getMappedWeather() }
    }
    
    func removeRowFromRealmBD(by date: Date) {
        let row = realm.objects(WeatherRealmDB.self).filter("date == %@", date).first
        do {
            guard let row = row else { return }
            try self.realm.write({
                self.realm.delete(row)
            })
        } catch(let e) {
            print(e.localizedDescription)
        }
    }
    
    func clearRealmBD() {
        let weathers = realm.objects(WeatherRealmDB.self)
        do {
            try self.realm.write({
                self.realm.delete(weathers)
            })
        } catch(let e) {
            print(e.localizedDescription)
        }
    }
    
    func getObserverWeatherRealmBD(by source: String) -> Results<WeatherRealmDB> {
        return realm.objects(WeatherRealmDB.self).filter("source == %@", source)
    }
}
