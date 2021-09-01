//
//  ActivityViewController.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/17/21.
//

import SwiftUI
import LinkPresentation

class LinkPresentationItemSource: NSObject, UIActivityItemSource {
    var linkMetadata = LPLinkMetadata()
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        return linkMetadata
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "Placeholder"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return linkMetadata.originalURL
    }
    
    init(metadata: LPLinkMetadata) {
        self.linkMetadata = metadata
    }
    
    
}

struct ActivityViewController: UIViewControllerRepresentable {
//    var metadata: LPLinkMetadata
//    var activityItems: [Any]
    var place: PlaceAnnotation?
    var url: URL?
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
//        let metadata = LPLinkMetadata()
//        if let url = URL(string: "https://maps.apple.com/?daddr=\(place?.address ?? "")") {
//            metadata.originalURL = url
//            metadata.url = metadata.originalURL
//            print(place?.address ?? "")
//            print(metadata.originalURL ?? "")
//        }
//        metadata.title = place?.title
        
        
//        let metadataItemSource = LinkPresentationItemSource(metadata: metadata)
        let activityItems: [Any] = [""]
        let ac = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        
        return ac
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
    
    
    
    
    
    
    
    
    
    // come back for LPLinkMetadata; will need a controller/delegate first
}

struct ActivityViewController_Previews: PreviewProvider {
    static var previews: some View {
        ActivityViewController()
    }
}
