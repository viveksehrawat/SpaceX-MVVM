//
//  HomeViewModel.swift
//  SpaceX-MVVM
//
//  Created by Vivek Sehrawat on 11/08/23.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject{
    
    @Published private var launchesList = [Launch]()
    @Published var searchText = ""
    
    var filteredLaunches : [Launch] {
        return searchText == "" ? launchesList : launchesList.filter { $0.mission_name.contains(searchText.lowercased())
        }
    }

    let provider = ServiceProvider<HomeService>()
    
    func getAllLaunches(){
        
        provider.load(service: .allLaunches, decodeType: [Launch].self){
            [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let launches):
                self.launchesList = launches
                print("Mission --> \(launches[0].mission_name)")
            case .failure(let error):
                print(error.localizedDescription)
            case .empty:
                print("No Data")
            }
        }
    }
}
