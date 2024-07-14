//
//  WeatherViewController.swift
//  WeatherApiApp
//
//  Created by *石岡顕* on 2024/07/09.
//  Copyright (c) 2024 *ReNKCHANNEL*. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation // 位置情報を取得するために必要なモジュールをインポートする。

class WeatherViewController: UIViewController {
    
    @IBOutlet private var max: UILabel!
    @IBOutlet private var min: UILabel!
    @IBOutlet private var taikan: UILabel!
    @IBOutlet private var humidity: UILabel!
    @IBOutlet private var wind: UILabel!
    private var currentLocation: CLLocation?
    // 位置情報を取得するために必要なプロトコルを付与する。
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self // CLLocationManagerDelegateプロトコルを使用するためにdelegateをViewControllerクラスに設定する。
        locationManager.requestWhenInUseAuthorization() // 位置情報の許可設定を通知する。
    }
    
    @IBAction func getLocation(_ sender: Any) {
        locationManager.requestLocation()
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        currentLocation = loc
        getWeatherData(latitude: String(currentLocation?.coordinate.latitude ?? 0), longitude: String(currentLocation?.coordinate.longitude ?? 0))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報取得エラー: \(error)")
    }
}

extension WeatherViewController {
    private func getWeatherData(latitude: String, longitude: String) {
        let API_KEY = "4427c745cb0f68ef58840352e8f43ab2"
        let urlString = "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=\(API_KEY)"
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        AF.request(encodedUrlString, method: .get, parameters: nil, encoding: JSONEncoding.default).responseData { [weak self] (response) in
            guard let self else { return }
            switch response.result {
            case .success:
                let json = JSON(response.data as Any)
                guard let maxTemp = json["main"]["temp_max"].number else { return }
                guard let minTemp = json["main"]["temp_min"].number else { return }
                guard let taikanTemp = json["main"]["temp"].number else { return }
                guard let currentHumi = json["main"]["humidity"].number else { return }
                guard let windVelo = json["wind"]["speed"].number else { return }
                
                self.max.text = "最高気温: \(Int(truncating: maxTemp).description)℃"
                self.min.text = "最低気温: \(Int(truncating: minTemp).description)℃"
                self.taikan.text = "体感温度: \(Int(truncating: taikanTemp).description)℃"
                self.humidity.text = "湿度: \(Int(truncating: currentHumi).description)%"
                self.wind.text = "風速: \(Int(truncating: windVelo).description)m/s"
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
