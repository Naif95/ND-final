//
//  WeatherViewController.swift
//  VirtualTourist
//
//  Created by Naif on 27/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {
    
    override func viewDidLoad() {
        self.view.backgroundColor = .gray
//        indicator.startAnimating()
        startView(true)
        getWeatherDetails()
        super.viewDidLoad()
    }
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var currValue: UILabel!
    @IBOutlet weak var maxValue: UILabel!
    @IBOutlet weak var minValue: UILabel!
    @IBOutlet weak var humValue: UILabel!
    @IBOutlet weak var likeValue: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let weatherClint = WeatherClass()
    var long : Double = 0.0
    var lat: Double = 0.0
    
    
    func getWeatherDetails () {
        weatherClint.getLocationWeather(long, lat) { (data, icon,status) in
            guard status == nil else
            {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                displayAlert.displayAlert(message: "Error in internet Connection, please try again later", title: "Connection Error", vc: self,  shouldReturn: false)
                return
            }
            
            guard let data = data else {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                displayAlert.displayAlert(message: "No data found", title: "Error", vc: self, shouldReturn: false)
                return
            }
            DispatchQueue.main.async {
                let url = URL(string: "https://openweathermap.org/img/wn/\(icon!)@2x.png")
                let imageData = try? Data(contentsOf: url!)
                self.image.image = UIImage(data: imageData!)
                self.currValue.text = "\(Double(round(1000*(data.temp! - 273.15)/1000))) °C"
                self.maxValue.text = "\(Double(round(1000*(data.tempMax! - 273.15)/1000))) °C"
                self.minValue.text = "\(Double(round(1000*(data.tempMin! - 273.15)/1000))) °C"
                self.humValue.text = "\(data.humidity!)"
                self.likeValue.text = "\(Double(round(1000*(data.feelsLike! - 273.15)/1000))) °C"
                self.view.backgroundColor = .white
                self.indicator.isHidden = true
                self.startView(false)
            }
        }
    }
    
    func startView(_ status: Bool) {
        image.isHidden = status
        currValue.isHidden = status
        maxValue.isHidden = status
        minValue.isHidden = status
        humValue.isHidden = status
        likeValue.isHidden = status
        self.indicator.isHidden = !status
    }
}
