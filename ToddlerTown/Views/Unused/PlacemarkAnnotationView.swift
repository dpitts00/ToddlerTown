//
//  PlacemarkAnnotationView.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 8/3/21.
//

import SwiftUI

struct Triangle: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLines([
            CGPoint(x: rect.minX, y: rect.midY),
            CGPoint(x: rect.maxX, y: rect.midY),
            CGPoint(x: rect.midX, y: rect.maxY)
        ])
        
        return path
    }
}

struct MarkerShape: View {
    var color: Color
    var size: CGFloat? = 24
    
    var body: some View {
        ZStack {
            
            Circle()
                .foregroundColor(color)
                .frame(width: size, height: size, alignment: .center)
            Triangle()
                .fill(color)
                .frame(width: size, height: (size ?? 24) * 1.25, alignment: .center)
            
        }
    }
}

struct PlacemarkAnnotationView: View {
    var selected: Bool
    var size: CGFloat? = 24
    
    var body: some View {
        MarkerShape(color: selected ? Color.blue : Color.red, size: size)
    }
}

struct PlacemarkAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        PlacemarkAnnotationView(selected: false)
    }
}
