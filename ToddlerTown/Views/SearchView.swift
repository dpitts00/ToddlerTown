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
    
    let placeTypes = PlaceType.allCases
    let placeTypeCategories = ["All", "Favorites", "Attractions", "Restaurants & Cafés", "Parks & Nature", "Stores", "Libraries", "Friends & Family", "Other"]
    let placeTypeImages = ["All": "mappin", "Favorites": "heart", "Parks & Nature": "leaf", "Restaurants & Cafés": "rectangle.roundedbottom", "Attractions": "ticket", "Friends & Family": "person", "Libraries": "text.book.closed", "Stores": "cart", "Other": "mappin"]
//    let placeTypeColors: [String: Color] = ["All": .pink, "Favorites": .red, "Parks & Nature": .green, "Restaurants & Cafés": .blue, "Attractions": .purple, "Friends & Family": .red, "Libraries": .orange, "Stores": .yellow, "Other": .pink]
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default) private var places: FetchedResults<PlaceAnnotation>
    
    var body: some View {
        
        let placeTypeColors: [String: Color] = ["All": MyColors.red, "Favorites": MyColors.blue, "Parks & Nature": MyColors.red, "Restaurants & Cafés": MyColors.gold, "Attractions": MyColors.blueGreen, "Friends & Family": MyColors.gold, "Libraries": MyColors.blueGreen, "Stores": MyColors.blue, "Other": MyColors.red]
        
        NavigationView {
            ScrollView {
                VStack {
                    Image("block.city")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, 8)
                                        
                    ForEach(placeTypeCategories, id: \.self) { type in
                        NavigationLink(destination: ContentView(type: type)) {
                            HStack {
                                Text(type)
                                Spacer()
                                if type == "Restaurants & Cafés" {
                                    Image("coffee.cup")
                                } else {
                                    Image(systemName: placeTypeImages[type] ?? "mappin")
                                }
                            }
                            .font(.headline)
                            .padding()
                            .background(placeTypeColors[type] ?? .blue)
//                            .background(MyColors.red)
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
                    .foregroundColor(MyColors.blue)
                    .font(.headline)
                    .padding([.top, .trailing, .bottom])
                    , trailing: NavigationLink(destination: MapSearchTest()) {
                        Image(systemName: "plus")
                    }
                    .foregroundColor(MyColors.blue)
                    .font(.headline)
                    .padding([.leading, .top, .bottom])
    //                .background(Circle().stroke(Color.blue, lineWidth: 2))
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("ToddlerTown")
                            .fontWeight(.semibold)
                            .foregroundColor(MyColors.blue)
                            .font(.custom("Avenir Next", size: 24).lowercaseSmallCaps())
                    }
                }
            }
            .padding(.top, 16)
            .onAppear {
                if places.isEmpty {
                    infoShowing = true
                }
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
