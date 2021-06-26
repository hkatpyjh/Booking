import ObjectMapper

struct Book: Mappable, Hashable {
    var authors: String!
    var desc: String!
    var image: String!
    var isbn13: String!
    var language: String!
    var pages: String!
    var price: String!
    var publisher: String!
    var rating: String!
    var subtitle: String!
    var title: String!
    var url: String!
    var year: String!
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        authors   <- map["authors"]
        desc      <- map["desc"]
        image     <- map["image"]
        isbn13    <- map["isbn13"]
        language  <- map["language"]
        pages     <- map["pages"]
        price     <- map["price"]
        publisher <- map["publisher"]
        rating    <- map["rating"]
        subtitle  <- map["subtitle"]
        title     <- map["title"]
        url       <- map["url"]
        year      <- map["year"]
    }
}
