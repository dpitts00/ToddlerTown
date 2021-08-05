//
//  TextOutline.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 8/3/21.
//

import SwiftUI

struct TextOutline: View {
    let string: String = ""
    let offset: CGFloat = 1
    
    var body: some View {
        VStack {
            ZStack {
                Text(string)
                    .foregroundColor(.white)
                    .offset(x: offset, y: 0)
                Text(string)
                    .foregroundColor(.white)
                    .offset(x: -offset, y: 0)
                Text(string)
                    .foregroundColor(.white)
                    .offset(x: 0, y: offset)
                Text(string)
                    .foregroundColor(.white)
                    .offset(x: 0, y: -offset)
//                Text(string)
//                    .foregroundColor(.white)
//                    .offset(x: offset, y: offset)
//                Text(string)
//                    .foregroundColor(.white)
//                    .offset(x: offset, y: -offset)
//                Text(string)
//                    .foregroundColor(.white)
//                    .offset(x: -offset, y: offset)
//                Text(string)
//                    .foregroundColor(.white)
//                    .offset(x: -offset, y: -offset)
                Text(string)
                    .foregroundColor(.black)
            }
            
            .padding()
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .frame(width: 100)
            .font(.caption)
        
        }
    }
    
}

struct TextOutline_Previews: PreviewProvider {
    static var previews: some View {
        TextOutline()
    }
}
