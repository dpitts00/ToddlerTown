//
//  UserLocationIndicatorView.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/15/21.
//

import SwiftUI
import MapKit

struct UserLocationIndicatorView: View {
    @Binding var showingUserLocation: Bool
    
    var body: some View {
        Image(systemName: showingUserLocation ? "location.fill" : "location.slash.fill")
            .font(.title2)
            .foregroundColor(.white)
            .padding()
            .background(showingUserLocation ? Color.blue : Color.gray)
            .clipShape(Circle())
        
    }
    
    
    func isUserLocationShowing() {
        let locationManager = CLLocationManager()
        if locationManager.location != nil {
            showingUserLocation = true
        }
    }
}

struct UserLocationIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        UserLocationIndicatorView(showingUserLocation: .constant(true))
    }
}
