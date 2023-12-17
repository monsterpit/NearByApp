//
//  ViewController.swift
//  NearByApp
//
//  Created by Vikas Salian on 16/12/23.
//

import Combine
import CoreLocation
import UIKit

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
    var subscriptions: Set<AnyCancellable> = []
    lazy var locManager = CLLocationManager()
    
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
    
    private func setupViewModelAndFetchData(){
        viewModel = FeedListingViewModel()
        viewModel.venues
            .receive(on: DispatchQueue.main)
            .sink { venues in
                print(venues)
                self.activityIndicator.isHidden = true
                self.venueTableView.reloadData()
            }
            .store(in: &subscriptions)
            
        fetchData()
    }
    
    private func fetchData(){
        activityIndicator.isHidden = false
        Task{
            await viewModel.fetchVenues(range: Int(rangeSlider.value))
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


extension ViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.venues.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueTableViewCell", for: indexPath) as! VenueTableViewCell
        
        cell.setupCell(title: viewModel.venues.value[indexPath.row].name, description: viewModel.venues.value[indexPath.row].venueAddress)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.venues.value.count - 1{
            fetchData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToDetail(url: viewModel.venues.value[indexPath.row].url)
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

extension ViewController: CLLocationManagerDelegate{
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        manageLocationPermissions(manager)
    }
    
    fileprivate func manageLocationPermissions(_ manager: CLLocationManager){
        switch manager.authorizationStatus{
        case .authorizedAlways,.authorizedWhenInUse:
            viewModel.setLocation(latitude: manager.location?.coordinate.latitude ?? 0,
                                  longitude: manager.location?.coordinate.longitude ?? 0)
        case .denied:
            showPermissionAlert() // Or requestAlwaysAuthorization()
        default:
            break
        }
    }
    
    private func showPermissionAlert() {
        let alertController = UIAlertController(
            title: "Location Access Denied",
            message: "To use this feature, you need to enable location services. Please go to Settings and enable location access for this app.",
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            // Open app settings when "Settings" button is tapped
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }
            
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        if let topViewController = UIApplication.shared.keyWindow?.rootViewController{
            topViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    fileprivate func askForLocation(){
        DispatchQueue.main.async { [weak self] in
            guard let self else {return}
            locManager.requestAlwaysAuthorization()
            locManager.delegate = self
            manageLocationPermissions(locManager)
        }
    }
 
}
