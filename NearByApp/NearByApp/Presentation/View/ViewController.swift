//
//  ViewController.swift
//  NearByApp
//
//  Created by Vikas Salian on 16/12/23.
//

import UIKit
import CoreLocation
final class ViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!{
        didSet{
            searchTextField.delegate = self
        }
    }
    @IBOutlet weak var venueTableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var rangeSlider: UISlider!
    @IBOutlet weak var sliderLabel: UILabel!
    var viewModel: FeedListingViewModelProtocol!
    var currentLocation: CLLocation!
    var latitude: Double = 0
    var longitude: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        setUpSlider()
        askForLocation()
        setuptabelView()
        setupViewModelAndFetchData()
        
    }
    
    private func setUpSlider(){
        rangeSlider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        sliderLabel.text = "Restraunts within the \(Int(rangeSlider.value)) kms of radius"
       
    }
    
    private func askForLocation(){
        var locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        if
           CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() ==  .authorizedAlways
        {
            currentLocation = locManager.location
            latitude = locManager.location?.coordinate.latitude ?? 0
            longitude = locManager.location?.coordinate.longitude ?? 0
        }
    }
    
    private func setupViewModelAndFetchData(){
        viewModel = FeedListingViewModel(delegate: self)
        fetchData()
    }
    
    private func fetchData(){
        activityIndicator.isHidden = false
        Task{
            await viewModel.fetchVenues(lat:latitude, lon: longitude, range: Int(rangeSlider.value))
        }
    }
    
    private func setuptabelView(){
        venueTableView.register(UINib(nibName: "VenueTableViewCell", bundle: nil), forCellReuseIdentifier: "VenueTableViewCell")
        venueTableView.delegate = self
        venueTableView.dataSource = self
    }

    @objc func sliderDidEndSliding(){
        sliderLabel.text = "Restraunts within the \(Int(rangeSlider.value)) kms of radius"
        fetchData()
    }

}


extension ViewController: FeedListingViewModelDelegate{
    func updateVenues() {
        print(viewModel.venues)
        DispatchQueue.main.async{
            self.activityIndicator.isHidden = true
            self.venueTableView.reloadData()
        }
       
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.venues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueTableViewCell", for: indexPath) as! VenueTableViewCell
        
        cell.setupCell(title: viewModel.venues[indexPath.row].name, description: viewModel.venues[indexPath.row].venueAddress)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.venues.count - 1{
            fetchData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToDetail(url: viewModel.venues[indexPath.row].url)
    }
    
    private func navigateToDetail(url: String){
        let ticketViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TicketViewController") as! TicketViewController
        ticketViewController.url = url
        navigationController?.pushViewController(ticketViewController, animated: false)
        
    }

}

extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.searchTerm = textField.text ?? ""
        fetchData()
        return true
    }
}
