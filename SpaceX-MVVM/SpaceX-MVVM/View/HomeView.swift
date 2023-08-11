//
//  HomeView.swift
//  SpaceX-MVVM
//
//  Created by Vivek Sehrawat on 11/08/23.
//

import SwiftUI
import Foundation
import Combine

struct HomeView: View {
    
    @StateObject private var spacexVM = HomeViewModel()
    
    var body: some View {
        NavigationView{
            List(spacexVM.filteredLaunches, id: \.id) { launch in
                NavigationLink(destination: LaunchDetailView(launch: launch)){
                    HomeViewRow(launch: launch)
                }
            }
            .searchable(text: $spacexVM.searchText)
            .navigationTitle("SpaceX")
        }.onAppear {
            Task {
                spacexVM.getAllLaunches()
                
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct HomeViewRow: View {
    let launch: Launch
    
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Text(launch.mission_name).font(.title).fontWeight(.light)
                Spacer()
                Divider()
                Text(launch.launch_year)
            }
        }
    }
}

