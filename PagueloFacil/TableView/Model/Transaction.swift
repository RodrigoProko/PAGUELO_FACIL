import Foundation

struct Transaction: Codable {
    var amount: Float?
    var idTransaction: Int?
    var status: Int?
    var merchantName: String?
    var ipCountry: String?
    var email: String?
    var phone: String?
    var cardType: String?
    var dateTms: String?
    var address: String?
    var txConcept: String?
}

extension Transaction {
    static let API_URL: String = {
        return "https://sandbox.paguelofacil.com/PFManagementServices/api/v1/MerchantTransactions"
    }()
    
    static let API_TOKEN: String = {
        return "brEyQRSzMm2UwQa5v0NsobRa3U8nH5xT|DIRkSivF8isxeVQpZNrNE12Xc"
    }()
    
    static func countItems() async throws -> Int {
        let urlString = API_URL+"?field=idTransaction::COUNT"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue(API_TOKEN, forHTTPHeaderField: "Authorization")
        let (res, _) = try await  URLSession.shared.data(for: request)
        let jsonString = String(data: res, encoding: .utf8) ?? ""
        let data = jsonString.components(separatedBy: ["[","]"])
        if(data.count < 1) {
            return 0
        }
        return Int(data[1]) ?? 0
    }
    
    static func requestTransactions(offset: Int, params: String?) async throws -> [Transaction] {
        var urlString = API_URL
        urlString += "?offset=" + String(offset)
        urlString += params == nil ? "&limit=18" : (params ?? "")
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue(API_TOKEN, forHTTPHeaderField: "Authorization")
        let (res, _) = try await  URLSession.shared.data(for: request)
        let jsonString = String(data: res, encoding: .utf8) ?? ""
        let jsonData = jsonString.data(using: .utf8)!
        let response: TransactionsModel = try! JSONDecoder().decode(TransactionsModel.self, from: jsonData)
        return response.data
    }
    
    static func searchTransactions(filters: [[String: String]], sortBy: [String: String]) async throws -> [Transaction] {
        var transactions: [Transaction] = []
        var params: String = filters.count > 0 ? "&Conditional=": ""
        
        for i in 0..<filters.count {
            if(filters[i]["isNumber"] == "1") {
                let number = Int(filters[i]["value"] ?? "")
                if(number == nil) {
                    return []
                }
                let field = String(filters[i]["field"] ?? "")
                let op = String(filters[i]["operator"] ?? "")
                let value = String(filters[i]["value"] ?? "")
             
                params += field+op+value
                if(i != filters.count - 1) {
                    params += "%7C"
                }
            }
        }

        params += filters.count > 0 ? "&" : ""
        if(sortBy != [:]) {
            let field = String(sortBy["field"] ?? "")
            let op = String(sortBy["operator"] ?? "")
            let value = String(sortBy["value"] ?? "")
            params += "&"+field+op+value
        }
        transactions.append(contentsOf: try await Transaction.requestTransactions(offset: 0, params: params))
        return transactions
    }
}
