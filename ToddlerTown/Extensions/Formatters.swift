//
//  Formatters.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 8/31/21.
//

import Contacts

extension CNPostalAddressFormatter {
    static var shared = CNPostalAddressFormatter()
}



extension NumberFormatter {
    static var shared: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }
}
