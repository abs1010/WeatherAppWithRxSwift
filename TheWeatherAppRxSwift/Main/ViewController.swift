//
//  ViewController.swift
//  TheWeatherAppRxSwift
//
//  Created by Alan Silva on 03/12/20.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var cityTemp: UILabel!
    @IBOutlet weak var cityHumidity: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cityTextField.rx.controlEvent(.editingDidEndOnExit)
        .asObservable()
            .map { self.cityTextField.text }
            .subscribe(onNext: { city in
                
                if let city = city {
                    if city.isEmpty {
                        self.displayWeather(nil)
                    } else {
                        self.fetchWeather(by: city)
                    }
                }
                
            }).disposed(by: disposeBag)
        
        
    }
    
    private func fetchWeather(by city: String) {
        
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed), let url = URL.urlForWeather(cityEncoded) else {
            return
        }
        
        let resource = Resource<Weather>(url: url)
        
        let search = URLRequest.request(resource: resource)
            .observeOn(MainScheduler.instance)
            .asDriver(onErrorJustReturn: Weather.empty)
        
        search.map { "\($0.main?.temp ?? 0) ℉" }
        .drive(self.cityTemp.rx.text)
        .disposed(by: disposeBag)
        
        search.map { "\($0.main?.humidity ?? 0) 💦" }
        .drive(self.cityHumidity.rx.text)
        .disposed(by: disposeBag)
        
    }
    
    private func displayWeather(_ weather: Main?) {
        
        if let weather = weather {
            self.cityTemp.text = "\(weather.temp ?? 0.0) ℉"
            self.cityHumidity.text = "\(weather.humidity ?? 0) 💧"
        } else {
            self.cityTemp.text = "🚫"
            self.cityHumidity.text = "🚫"
        }
        
    }
    
}

