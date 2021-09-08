//
//  ActivityViewController.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 9/1/21.
//

import UIKit
import LinkPresentation

class ActivityController: UIViewController, UIActivityItemSource {
    var metadata: LPLinkMetadata?
    var activityViewController: UIActivityViewController?
    var completion: UIActivityViewController.CompletionWithItemsHandler?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        activityViewController = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        activityViewController?.completionWithItemsHandler = completion
        present(activityViewController!, animated: true)
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return metadata?.originalURL
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        return metadata
    }
    
    
}

