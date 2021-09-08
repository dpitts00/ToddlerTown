//
//  MapLinkView.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 9/1/21.
//

import Foundation
import LinkPresentation

class MapLinkView {
    class func getMetadata(_ urlString: String, completion: @escaping (Result<LPLinkMetadata, Error>) -> Void) {
        // Result has .success() case and .failure() case
        guard let url = URL(string: urlString) else { return }
        let metadataProvider = LPMetadataProvider()
        metadataProvider.startFetchingMetadata(for: url) {
            (metadata, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let metadata = metadata {
                completion(.success(metadata))
            }
        }
        // LPLinkMetadata will contain URL, title, icon, image, video
        
    }
}
