//
//  SearchView.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/21/21.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var infoShowing = false
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var places: FetchedResults<PlaceAnnotation>
    
    var body: some View {
                
        NavigationView {
            ScrollView {
                VStack {
                    Image("block.city")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, 8)
                                        
                    ForEach(PlaceType.allCases, id: \.self) { type in
                        NavigationLink(destination: ContentView(type: type)) {
                            HStack {
                                Text(type.rawValue)
                                Spacer()
                                type.imageForType()
                            }
                            .font(.headline)
                            .padding()
                            .background(type.color())
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    
                }
                .padding(.horizontal)
                .navigationBarItems(
                    leading: Button(action: {
                        infoShowing = true
                    }) {
                        Image(systemName: "info.circle")
                    }
                    .foregroundColor(.ttBlue)
                    .font(.headline)
                    .padding([.top, .trailing, .bottom])
                    , trailing: NavigationLink(destination: AddPlaceView()) {
                        Image(systemName: "plus")
                    }
                    .foregroundColor(.ttBlue)
                    .font(.headline)
                    .padding([.leading, .top, .bottom])
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("ToddlerTown")
                            .fontWeight(.semibold)
                            .foregroundColor(.ttBlue)
                            // this is canceled out then...
                            .font(.custom("Avenir Next", size: 24).lowercaseSmallCaps())
                    }
                }
            }
            .padding(.top, 16)
            .onAppear {
                let defaults = UserDefaults.standard
                if defaults.object(forKey: "returningUser") == nil {
                    defaults.setValue("true", forKey: "returningUser")
                    infoShowing = true
                }
            }
            .sheet(isPresented: $infoShowing) {
                GettingStartedView()
            }
        } // for NavView
        .accentColor(.ttBlue)
        
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
