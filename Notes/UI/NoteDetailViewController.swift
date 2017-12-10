import UIKit
import CoreData
import MapKit
import QuartzCore

final class NoteDetailViewController: UIViewController, StoryboardInitializable {

    @IBOutlet var textView: UITextView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var createdLabel: UILabel!
    @IBOutlet var modifiedLabel: UILabel!
    @IBOutlet var addLocationButton: UIButton!
    @IBOutlet var addPhotoButton: UIButton!

    var note: Note?
    var dataManager: DataManager?
    let dateFormatter = DateFormatter()
    private var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium

        textView.delegate = self

        updateUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if textView.text == "New note" {
            textView.selectAll(nil)
            textView.becomeFirstResponder()
        }
    }

    func updateUI() {
        guard let note = note else { return }

        textView.text = note.text

        if let createdDate = note.createdAt  {
            createdLabel.text = dateFormatter.string(from: createdDate as Date)
        } else {
            createdLabel.text = nil
        }

        if let modifiedDate = note.modifiedAt {
            modifiedLabel.text = dateFormatter.string(from: modifiedDate as Date)
        } else {
            modifiedLabel.text = nil
        }

        setupMap()
        setupPhoto()
    }

    @IBAction func addPhoto(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let alert = UIAlertController(title: "Camera", message: "Camera is not available.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
            return
        }

        let cameraPicker = UIImagePickerController()
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false
        cameraPicker.delegate = self
        present(cameraPicker, animated: true, completion: nil)
    }

    @IBAction func addLocation(_ sender: UIButton) {
        guard CLLocationManager.locationServicesEnabled() else {
            let alert = UIAlertController(title: "Location", message: "Location service is not enabled. Please check your settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
            return
        }
        startLocationServices()
    }

    func setupMap() {
        if let hasLocation = note?.hasLocation, hasLocation == true,
            let latitude = note?.latitude, let longitude = note?.longitude {
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            mapView.setRegion(MKCoordinateRegion.init(center: location, span: MKCoordinateSpanMake(0.01, 0.01)), animated: true)
            mapView.isHidden = false
            
            addLocationButton.isHidden = true
        } else {
            mapView.isHidden = true;
            addLocationButton.layer.cornerRadius = 10
            addLocationButton.isHidden = false
        }
    }

    func setupPhoto() {
        if let data = note?.image {
            imageView.image = UIImage(data: data as Data)
            imageView.isHidden = false
            addPhotoButton.isHidden = true
        } else {
            imageView.isHidden = true
            addPhotoButton.layer.cornerRadius = 10
            addPhotoButton.isHidden = false
        }
    }

    @objc func endEditingAndSave() {
        textView.resignFirstResponder()
    }

    func startLocationServices() {
        if locationManager == nil {
            locationManager = CLLocationManager()
        }

        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 500

        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
            locationManager?.requestWhenInUseAuthorization()
        } else {
            locationManager?.startUpdatingLocation()
        }
    }

    func updateMapAndNote(with location: CLLocation) {
        note?.latitude = location.coordinate.latitude
        note?.longitude = location.coordinate.longitude
        note?.hasLocation = true
        note?.modifiedAt = Date()
        dataManager?.saveContext()
        setupMap()
    }
}

extension NoteDetailViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(endEditingAndSave))
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        navigationItem.rightBarButtonItem = nil
        note?.text = textView.text
        note?.modifiedAt = Date()
        dataManager?.saveContext()
        updateUI()
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
}

extension NoteDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true) {
            guard let photo = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
            guard let photoData = UIImageJPEGRepresentation(photo, 0.0) as Data? else { return }
            self.note?.image = photoData
            self.note?.modifiedAt = Date()
            self.dataManager?.saveContext()
            self.setupPhoto()
        }
    }
}

extension NoteDetailViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let timestamp = location.timestamp
            let interval = -timestamp.timeIntervalSinceNow
            if interval <= 30 {
                manager.stopUpdatingLocation()
                updateMapAndNote(with: location)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("User has not authorized yet")
        case .authorizedWhenInUse:
            fallthrough
        case .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            let alert = UIAlertController(title: "Location", message: "Location service is not authorized. Please check your settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}
