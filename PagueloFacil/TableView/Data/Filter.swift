import Foundation
class Filter {
    static let DATE_FILTER: [String: String] = {
        return [
            "field": "Sort",
            "operator": "=",
            "value": "-dateTms",
            "isNumber": "0"
        ]
    }()
    
    static let APPROVED_FILTER: [String: String] = {
        return [
            "field": "status",
            "operator": "$eq",
            "value": "1",
            "isNumber": "1"
        ]
    }()
    
    static let AMOUNT_FILTER: [String: String] = {
        return [
            "field": "Sort",
            "operator": "=",
            "value": "amount",
            "isNumber": "0"
        ]
    }()
    
    static let AMOUNT: String = {
        return "Amount"
    }()
    
    static let DATE: String = {
        return "Date"
    }()
    
    static let ALL: String = {
        return "All"
    }()
    
    
    static let APPROVED: String = {
        return "Approved"
    }()

}

