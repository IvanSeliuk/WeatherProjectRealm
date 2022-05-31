//
//  ShowHistoryRequestViewController.swift
//  WeatherProject
//
//  Created by Иван Селюк on 17.04.22.
//

import UIKit
import RealmSwift

class ShowHistoryRequestViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var removeAllButton: UIButton!
    
    private var observerWeathersCityToken: NotificationToken?
    private var observerWeathersMapToken: NotificationToken?
    
    deinit {
        observerWeathersCityToken?.invalidate()
        observerWeathersCityToken = nil
        observerWeathersMapToken?.invalidate()
        observerWeathersMapToken = nil
    }
    
    var arrayCityOffline = [WeatherDate]() {
        didSet {
            tableView.reloadData()
        }
    }
    var arrayMapOffline = [WeatherDate]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observerMapWeather()
        observerCityWeather()
        
    }
    
    private func observerCityWeather() {
        self.observerWeathersCityToken = RealmManager.shared.getObserverWeatherRealmBD(by: SourceValue.city.rawValue).observe({ [weak self] collection in
            self?.observeWeatherRealmDB(with: collection, type: .city)
        })
    }
    
    private func observerMapWeather() {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        segmentControlAction()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.popViewController(animated: true)
        MediaManager.shared.clearSoundPlayer()
    }
    
    private func setupUI() {
        setupButton()
        setupSegmentStyle()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherTableViewCell")
        tableView.register(UINib(nibName: "HistoryWeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryWeatherTableViewCell")
    }
    
    private func setupSegmentStyle() {
        segmentControl.setTitle("tabBarItem.map".localized, forSegmentAt: 0)
        segmentControl.setTitle("City".localized, forSegmentAt: 1)
    }
    
    private func setupButton() {
        removeAllButton.layer.cornerRadius = 7
        removeAllButton.setTitle("Remove All".localized, for: .normal)
    }
    
    private func buttonIsHidden() {
        if arrayMapOffline.count == 0, arrayCityOffline.count == 0 {
            removeAllButton.isHidden = true
        } else {
            removeAllButton.isHidden = false
        }
    }
    
    func segmentControlAction() {
        if segmentControl.selectedSegmentIndex == 0 {
            arrayMapOffline.removeAll()
            let source = RealmManager.shared.getWeatherWithRealmBD(by: SourceValue.map.rawValue)
            arrayMapOffline.append(contentsOf: source)
        } else {
            arrayCityOffline.removeAll()
            let city = RealmManager.shared.getWeatherWithRealmBD(by: SourceValue.city.rawValue)
            arrayCityOffline.append(contentsOf: city)
        }
        buttonIsHidden()
    }
    
    @IBAction func segmentControlAction(_ sender: Any) {
        MediaManager.shared.playSoundPlayer(with: SoundsChoice.click.rawValue)
        segmentControlAction()
    }
    
    @IBAction func removeAllDataBaseAction(_ sender: Any) {
        MediaManager.shared.playSoundPlayer(with: SoundsChoice.delete.rawValue)
        RealmManager.shared.clearRealmBD()
        arrayMapOffline.removeAll()
        arrayCityOffline.removeAll()
        removeAllButton.isHidden = true
        tableView.reloadData()
    }
}

extension ShowHistoryRequestViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch segmentControl.selectedSegmentIndex {
        case 0: return arrayMapOffline.count
        case 1: return arrayCityOffline.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryWeatherTableViewCell", for: indexPath) as? HistoryWeatherTableViewCell else { return UITableViewCell() }
            cell.setupParametresWithMap(with: arrayMapOffline[indexPath.section])
            cell.userClickRemoveRowInMap = { [weak self] in
                self?.segmentControlAction() }
            cell.selectionStyle = .none
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as? WeatherTableViewCell else { return UITableViewCell() }
            cell.setupParametresWithCity(with: arrayCityOffline[indexPath.section])
            cell.userClickRemoveRowInCity = { [weak self] in
                self?.segmentControlAction() }
            cell.animationView.backgroundColor = UIColor(named: "ColorView")
            cell.selectionStyle = .none
            return cell
            
        default: return UITableViewCell()
        }
    }
}

extension ShowHistoryRequestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch segmentControl.selectedSegmentIndex {
        case 0: return 87.0
        case 1: return 218.0
        default: return 44.0
        }
    }
    
    // MARK: отступы между TableViewCell (grouped, height header = 3, cell - через section, а не Row)
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
}
