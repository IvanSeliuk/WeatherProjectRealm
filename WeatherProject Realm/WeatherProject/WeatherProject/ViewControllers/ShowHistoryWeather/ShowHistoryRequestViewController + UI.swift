//
//  ShowHistoryRequestViewController + UI.swift
//  WeatherProject
//
//  Created by Иван Селюк on 7.06.22.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

extension ShowHistoryRequestViewController {
    func observerCityWeather() {
        self.observerWeathersCityToken = RealmManager.shared.getObserverWeatherRealmBD(by: SourceValue.city.rawValue).observe({ [weak self] collection in
            self?.observeWeatherRealmDB(with: collection, type: .city)
        })
    }
    
    func observerMapWeather() {
        self.observerWeathersMapToken = RealmManager.shared.getObserverWeatherRealmBD(by: SourceValue.map.rawValue).observe({ [weak self] collection in
            self?.observeWeatherRealmDB(with: collection, type: .map)
        })
    }
    
    func observeWeatherRealmDB(with collection: RealmCollectionChange<Results<WeatherRealmDB>>, type: SourceValue) {
        switch collection {
        case .initial(let collection):
            if type == SourceValue.map {
                print("MAP:")
            } else {
                print("CITY:")
            }
            print("initial count weathers: \(collection.count)")
        case .update(let collection, deletions: let del, insertions: let ins, modifications: let mod):
            print("update count weathers: \(collection.count)")
            print("deleted")
            print(del)
            print("inserted")
            print(ins)
            print("modification")
            print(mod)
        default: break
        }
    }
    
    func setupUI() {
        setupTableView()
        setupButton()
        setupSegmentStyle()
    }
    
    private func setupTableView() {
        tableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherTableViewCell")
        tableView.register(UINib(nibName: "HistoryWeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryWeatherTableViewCell")
        
        weatherDataSource
            .bind(to: tableView.rx.items) { (tableView, index, model) -> UITableViewCell in
                
                if self.segmentControl.selectedSegmentIndex == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryWeatherTableViewCell") as! HistoryWeatherTableViewCell
                    cell.setupParametresWithMap(with: model)
                    cell.userClickRemoveRowInMap = { [weak self] in
                        self?.setupSegmentControl() }
                    cell.selectionStyle = .none
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell") as! WeatherTableViewCell
                    cell.setupParametresWithCity(with: model)
                    cell.userClickRemoveRowInCity = { [weak self] in
                        self?.setupSegmentControl() }
                    cell.animationView.backgroundColor = UIColor(named: "ColorView")
                    cell.selectionStyle = .none
                    return cell
                }
            }.disposed(by: disposeBag)
    }
    
    private func setupSegmentStyle() {
        segmentControl.setTitle("tabBarItem.map".localized, forSegmentAt: 0)
        segmentControl.setTitle("City".localized, forSegmentAt: 1)
    }
    
    private func setupButton() {
        removeAllButton.layer.cornerRadius = 7
        removeAllButton.setTitle("Remove All".localized, for: .normal)
        
        removeAllButton
            .rx
            .tap
            .bind {
                MediaManager.shared.playSoundPlayer(with: SoundsChoice.delete.rawValue)
                RealmManager.shared.clearRealmBD()
                self.weatherDataSource.onNext([])
                self.removeAllButton.isHidden = true
                self.tableView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    func setupSegmentControl() {
        if segmentControl.selectedSegmentIndex == 0 {
            let source = RealmManager.shared.getWeatherWithRealmBD(by: SourceValue.map.rawValue)
            weatherDataSource.onNext(source)
        } else {
            let city = RealmManager.shared.getWeatherWithRealmBD(by: SourceValue.city.rawValue)
            weatherDataSource.onNext(city)
        }
        removeAllButton.isHidden = try! weatherDataSource.value().count == 0
    }
}
