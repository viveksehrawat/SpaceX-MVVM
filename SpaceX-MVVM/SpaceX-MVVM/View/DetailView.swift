//
//  DetailView.swift
//  SpaceX-MVVM
//
//  Created by Vivek Sehrawat on 11/08/23.
//

import SwiftUI

// Separate detail view for launches
struct LaunchDetailView: View {
    let launch: Launch
    
    var body: some View {
        Text("Details of \(launch.mission_name)") // Show more details here
    }
}
