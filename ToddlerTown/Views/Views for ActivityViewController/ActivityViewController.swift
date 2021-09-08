//
//  ActivityViewController.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 9/1/21.
//

import SwiftUI
import LinkPresentation

/*
struct ActivityViewController: UIViewControllerRepresentable {
//    var urlString = ""
    var metadata: LPLinkMetadata?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
//        let newURLString = urlString.replacingOccurrences(of: "+", with: "%20")
//        let urlEncodedString = URL(string: urlString)?.absoluteString ?? ""
        let ac = UIActivityViewController(activityItems: [metadata ?? "Place not found"], applicationActivities: nil)
        return ac
        
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
}
*/

struct ActivityViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = ActivityController
    
    var metadata: LPLinkMetadata?
    var completion: (() -> Void)
    
    func makeUIViewController(context: Context) -> ActivityController {
        let activityController = ActivityController()
        activityController.metadata = metadata
        activityController.completion = { (activityType, completed, returnedItems, error) in
            self.completion()
        }
        activityController.loadView()
        return activityController
    }
    
    func updateUIViewController(_ uiViewController: ActivityController, context: Context) {
        
    }
}

 
//struct ActivityViewController_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityViewController(completion: nil)
//    }
//}
