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
    
//    let placeTypes = PlaceType.allCases
//    let placeTypeCategories = ["All", "Favorites", "Attractions", "Restaurants & Cafés", "Parks & Nature", "Stores", "Libraries", "Friends & Family", "Other"]
//    let placeTypeImages = ["All": "mappin", "Favorites": "heart", "Parks & Nature": "leaf", "Restaurants & Cafés": "rectangle.roundedbottom", "Attractions": "ticket", "Friends & Family": "person", "Libraries": "text.book.closed", "Stores": "cart", "Other": "mappin"]
//    let placeTypeColors: [String: Color] = ["All": .pink, "Favorites": .red, "Parks & Nature": .green, "Restaurants & Cafés": .blue, "Attractions": .purple, "Friends & Family": .red, "Libraries": .orange, "Stores": .yellow, "Other": .pink]
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default) private var places: FetchedResults<PlaceAnnotation>
    
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
                    , trailing: NavigationLink(destination: Text("Add View goes here")) {
                        Image(systemName: "plus")
                    }
                    .foregroundColor(.ttBlue)
                    .font(.headline)
                    .padding([.leading, .top, .bottom])
    //                .background(Circle().stroke(Color.blue, lineWidth: 2))
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("ToddlerTown")
                            .fontWeight(.semibold)
                            .foregroundColor(.ttBlue)
                            .font(.custom("Avenir Next", size: 24).lowercaseSmallCaps())
                    }
                }
            }
            .padding(.top, 16)
            .onAppear {
//                if places.isEmpty {
//                    infoShowing = true
//                }
            }
            .sheet(isPresented: $infoShowing) {
                GettingStartedView()
            }
        }
        
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
