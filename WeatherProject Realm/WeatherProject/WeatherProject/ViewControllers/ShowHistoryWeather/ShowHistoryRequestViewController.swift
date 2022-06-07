//
//  ShowHistoryRequestViewController.swift
//  WeatherProject
//
//  Created by Иван Селюк on 17.04.22.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import CoreMedia

class ShowHistoryRequestViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var removeAllButton: UIButton!
    
    let disposeBag = DisposeBag()
    var weatherDataSource = BehaviorSubject<[WeatherDate]>(value: [])
    
    var observerWeathersCityToken: NotificationToken?
    var observerWeathersMapToken: NotificationToken?
    
    //MARK: - Life cicle VC
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observerMapWeather()
        observerCityWeather()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSegmentControl()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pushPopViewController()
        MediaManager.shared.clearSoundPlayer()
    }
    
    deinit {
        observerWeathersCityToken?.invalidate()
        observerWeathersCityToken = nil
        observerWeathersMapToken?.invalidate()
        observerWeathersMapToken = nil
    }
    
    //MARK: - Push
    private func pushPopViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segmentControlAction(_ sender: Any) {
        MediaManager.shared.playSoundPlayer(with: SoundsChoice.click.rawValue)
        setupSegmentControl()
    }
}

//MARK: - TableViewDelegate
extension ShowHistoryRequestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch segmentControl.selectedSegmentIndex {
        case 0: return 87.0
        case 1: return 218.0
        default: return 44.0
        }
    }
}
