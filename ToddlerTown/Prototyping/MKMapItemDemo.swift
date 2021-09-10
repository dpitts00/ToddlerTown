//
//  MKMapItemDemo.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 8/30/21.
//

import SwiftUI
import MapKit

struct MKMapItemDemo: View {
    
    var body: some View {
        VStack {
            Text("Hello, World!")
                .padding()
                .background(Color.ttRed)
            Text("Hello, World!")
                .padding()
                .background(Color.ttBlue)
            Text("Hello, World!")
                .padding()
                .background(Color.ttBlueGreen)
            Text("Hello, World!")
                .padding()
                .background(Color.ttGold)
        }
        .foregroundColor(.white)
    }
    
    func mapStuff() {
//        let mapItem = MKMapItem()

    }
    
}

struct MKMapItemDemo_Previews: PreviewProvider {
    static var previews: some View {
        MKMapItemDemo()
    }
}
