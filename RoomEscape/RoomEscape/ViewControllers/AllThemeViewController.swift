//
//  AllThemeViewController.swift
//  RoomEscape
//
//  Created by Noah's Ark on 2022/07/28.
//

import UIKit

class AllThemeViewController: UIViewController {
    
    @IBOutlet weak var criterionLabel: UILabel!
    @IBOutlet weak var allThemeTableView: UITableView!
    
    var themeByLocation: String = ""
    var themeByRecommendation: String = ""
    var themeRoomModels: [RoomModel] = []
    let jsonDataManager: JSONDataManager = JSONDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAllThemeLabel()
        
        allThemeTableView.delegate = self
        allThemeTableView.dataSource = self
        allThemeTableView.register(UINib(nibName: Constants.roomTableViewCell, bundle: nil), forCellReuseIdentifier: Constants.roomTableViewCell)
        
    }
    
    private func configureAllThemeLabel() {
        if themeByLocation != "" {
            criterionLabel.text = themeByLocation
        } else if themeByRecommendation != "" {
            criterionLabel.text = themeByRecommendation
        }
        
        // List with location information
        if criterionLabel.text == themeByLocation {
            themeRoomModels = jsonDataManager.roomData.filter { RoomModel in
                RoomModel.location == criterionLabel.text
            }
        }
        
        if criterionLabel.text == themeByRecommendation {
            let firstSpace = criterionLabel.text!.firstIndex(of: "테") ?? criterionLabel.text!.endIndex
            let recommendationLabel = criterionLabel.text![..<firstSpace]

            themeRoomModels = jsonDataManager.roomData.filter { RoomModel in
                RoomModel.genre == recommendationLabel
            }
        }
    }
}

extension AllThemeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "DetailViewControllerRef") as? DetailViewController else { return }
        
        viewController.roomIndex = indexPath.row
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension AllThemeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themeRoomModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.roomTableViewCell, for: indexPath) as! RoomTableViewCell
        let roomInfo = themeRoomModels[indexPath.row]
        let url = URL(string: roomInfo.image)

        cell.roomName?.text = roomInfo.title
        cell.storeName?.text = roomInfo.storeName
        cell.genre.text = roomInfo.genre
        cell.roomImage?.contentMode = .scaleToFill
        cell.roomImage?.clipsToBounds = true
        
        for i in 0 ..< roomInfo.difficulty {
            cell.stars?.arrangedSubviews[i].tintColor = UIColor(named: "star");
        }
        
        DispatchQueue.main.async {
            if let url = url {
                if let data = try? Data(contentsOf: url) {
                    cell.roomImage?.image = UIImage(data: data)
                } else {
                    cell.roomImage?.image = UIImage(systemName: "house")
                }
            }
        }
        
        return cell
    }
    
}
