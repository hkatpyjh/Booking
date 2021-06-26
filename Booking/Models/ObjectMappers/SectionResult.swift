import ObjectMapper

struct SectionResult: Mappable, Hashable {
    var error: String!
    var total: String!
    var page: String! = "1"
    var nextpage: Int = 0
    var hasMore: Bool!
    var books: [Book]!
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        page  <- map["page"]
        books <- map["books"]
        error <- map["error"]
        total <- map["total"]
        
        if let currentPage = Int.parse(from: page) {
            let totalCount = Int.parse(from: total)!
            let currentCount = 20 * currentPage
            
            if totalCount > currentCount {
                nextpage = currentPage + 1
                hasMore = true
            } else {
                hasMore = false
            }
        }
    }
    
    mutating func append(result: SectionResult) {
        error = result.error
        total = result.total
        page = result.page
        nextpage = result.nextpage
        hasMore = result.hasMore
        books.append(contentsOf: result.books)
    }
}
