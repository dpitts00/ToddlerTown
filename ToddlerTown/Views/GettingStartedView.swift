//
//  GettingStartedView.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 8/2/21.
//

import SwiftUI

struct GettingStartedView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Getting Started")
                    .fontWeight(.semibold)
                    .font(.custom("Avenir Next", size: 18))
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.ttBlue)
            
            TabView {
                ScrollView {
                    ZStack {
                        if colorScheme == .dark {
                            LinearGradient(gradient: Gradient(colors: [Color(white: 0.125), Color(white: 0.125), Color(white: 0.125), .ttBlue]), startPoint: .top, endPoint: .bottom)
                        } else {
                            LinearGradient(gradient: Gradient(colors: [Color.white, Color.white, Color.white, .ttBlue]), startPoint: .top, endPoint: .bottom)
                        }
                        
                        VStack {
                            Text("Welcome to ") + Text("ToddlerTown").fontWeight(.bold) + Text(", a map app for keeping track of all the kid-centric places in your neighborhood! Tap ") + Text(Image(systemName: "plus")).foregroundColor(Color.ttBlue).fontWeight(.bold) + Text(" to add places to your map, then view them as a map or list, filtered by place type.")
                                
                            
                            Image("Search")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.bottom, 32)
                            
                            Spacer()
                                
                        }
                        .tabItem {
                            Text("One")
                        }
                        .padding()
                    }
                }
                
                ScrollView {
                    ZStack {
                        if colorScheme == .dark {
                            LinearGradient(gradient: Gradient(colors: [Color(white: 0.125), Color(white: 0.125), Color(white: 0.125), .ttBlue]), startPoint: .top, endPoint: .bottom)
                        } else {
                            LinearGradient(gradient: Gradient(colors: [Color.white, Color.white, Color.white, .ttBlue]), startPoint: .top, endPoint: .bottom)
                        }
                        
                        VStack {
                            Text("On the ") + Text("Add Places").fontWeight(.bold) + Text(" view, you can search for new places and add them with the ") + Text(Image(systemName: "plus")).foregroundColor(Color.ttRed).fontWeight(.bold) + Text(" button. Select the place type, and add photos and notes about the place. ")

                            
                            Image("Add")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.bottom, 32)
                                
                            Spacer()
                        }
                        .tabItem {
                            Text("Two")
                        }
                        .padding()
                    }
                }

                
                ScrollView {
                    ZStack {
                        if colorScheme == .dark {
                            LinearGradient(gradient: Gradient(colors: [Color(white: 0.125), Color(white: 0.125), Color(white: 0.125), .ttBlue]), startPoint: .top, endPoint: .bottom)
                        } else {
                            LinearGradient(gradient: Gradient(colors: [Color.white, Color.white, Color.white, .ttBlue]), startPoint: .top, endPoint: .bottom)
                        }
                        
                        VStack {
                            Text("View all of your places on a map or a list. Center on your location (if enabled), or share your places. ") + Text("User location shown below is simulated.").italic()


                            Image("Map")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.bottom, 32)
                            
                            Spacer()
                        }
                        .tabItem {
                            Text("Three")
                        }
                        .padding()
                    }
                }
                
                ScrollView {
                    ZStack {
                        if colorScheme == .dark {
                            LinearGradient(gradient: Gradient(colors: [Color(white: 0.125), Color(white: 0.125), Color(white: 0.125), .ttBlue]), startPoint: .top, endPoint: .bottom)
                        } else {
                            LinearGradient(gradient: Gradient(colors: [Color.white, Color.white, Color.white, .ttBlue]), startPoint: .top, endPoint: .bottom)
                        }
                        
                        VStack {
                            Text("View all of your places on a map or a list. You can mark your favorites on the list view. ") + Text("Distance is calculated from a simulated user location.").italic()


                            Image("List")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.bottom, 32)
                                
                            Spacer()
                        }
                        .tabItem {
                            Text("Four")
                        }
                        .padding()
                    }
                }
                
                ScrollView {
                    ZStack {
                        if colorScheme == .dark {
                            LinearGradient(gradient: Gradient(colors: [Color(white: 0.125), Color(white: 0.125), Color(white: 0.125), .ttBlue]), startPoint: .top, endPoint: .bottom)
                        } else {
                            LinearGradient(gradient: Gradient(colors: [Color.white, Color.white, Color.white, .ttBlue]), startPoint: .top, endPoint: .bottom)
                        }
                        
                        VStack {
                            Text("Share your ToddlerTown places with friends and family! You can export all of your places as a \"ToddlerTown Places\" file, and share them via text, email, or AirDrop.")
                            
                            Image("Share")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.bottom, 32)
                                
                            Spacer()
                        }
                        .tabItem {
                            Text("Five")
                        }
                        .padding()
                    }
                }
                
                ScrollView {
                    ZStack {
                        if colorScheme == .dark {
                            LinearGradient(gradient: Gradient(colors: [Color(white: 0.125), Color(white: 0.125), Color(white: 0.125), .ttBlue]), startPoint: .top, endPoint: .bottom)
                        } else {
                            LinearGradient(gradient: Gradient(colors: [Color.white, Color.white, Color.white, .ttBlue]), startPoint: .top, endPoint: .bottom)
                        }
                        
                        VStack {
                            Text("View details for a place, get directions, or share the location with others and make plans for the day. Enjoy your ToddlerTown!", comment: "Explanation of page showing place details")

                            
                            Image("Detail")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.bottom, 32)
                                
                            Spacer()
                        }
                        .tabItem {
                            Text("Six")
                        }
                        .padding()
                    }
                }
                
            }
            .tabViewStyle(PageTabViewStyle())
                
        }
    }
}

struct GettingStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GettingStartedView()
    }
}
