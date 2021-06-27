struct Const {
    static let MSG_ADD_CONFIRM = "Would you like to add book to favorite？"
    static let MSG_DEL_CONFIRM = "Would you like to remove book from favorite?"
    static let MSG_NO_MORE_DATA = "No more data available"
    static let MSG_UNABLE_FETCH_DATA = "Unable fetch data"
    static let MSG_ADD_CATEGORY = "Enter new category name"
    static let MSG_NO_DATA_FIND = "No data find"
    static let MSG_NO_SEARCH_HISTORY = "No search history"
    static let MSG_DEFAULT_SEARCH_PLACEHOLDER = "Search"
    static let MSG_SEARCH_PLACEHOLDER = "title, author, ISBN or keywords"
    static let MSG_INPUT_NOT_EMPTY = "Input can not be empty."
    
    static let YES = "Yes"
    static let NO = "No"
    static let MORE = "More"
    static let DELETE = "Delete"
    static let HEART = "heart"
    static let HEART_FILL = "heart.fill"
    static let CLEAR = "Clear"
    static let SETTING_KEY = "booking_setting"
    static let PROFILE_IMG = "profile.jpeg"
    
    static let SECTION_TITLE_SEARCH_HISTORY = "History"
    static let SECTION_TITLE_RECOMMEND = "Recommend"
    static let SECTION_TITLE_CATEGORY = "Category"
    static let SECTION_TITLE_OTHERS = "Others"
    
    static let RECOMMEND_KEYWORD = [
        "Microsoft", "Cloud", "Azure", "AI", "Oracle", "Creative", "Html5", "Spring", "Apache", "Firebase", "Beginner"
    ]
    static let PRESET_SEGMENT_CATEGORY = [
        "Python", "Java", "Visual Basic", "JavaScript", "PHP", "SQL", "Swift", "Go", "Perl", "Ruby", "Kotlin", "Rust"
    ]
    static let PRESET_CATEGORY_MENU: [[String: Any]] = [
        ["text": "Development Language", "menuType": MenuType.Collasable.rawValue, "color": "#e963ad", "submenus": [
            ["text": "Swift"], ["text": "Object-C"], ["text": "Java"],
            ["text": "Visual Basic"], ["text": "Python"], ["text": "PHP"],
            ["text": "Javascript"], ["text": "Go"], ["text": "Ruby"], ["text": "C#"]
        ]
        ],
        ["text": "Framework", "menuType": MenuType.Collasable.rawValue, "color": "#42cbf5", "submenus": [
            ["text": "Spring Framework"], ["text": "JavaServer Faces"], ["text": "Struts"],
            ["text": "Vue"], ["text": "ASP.NET"]
        ]
        ],
        ["text": "Design", "menuType": MenuType.Collasable.rawValue, "color": "#ffe0bd", "submenus": [
            ["text": "Illustrator"], ["text": "Photoshop"], ["text": "Gimp"],
            ["text": "Adobe XD"], ["text": "Premiere Rush"], ["text": "Dreamweaver"],
            ["text": "Spark"], ["text": "InDesign"], ["text": "After Effects"]
        ]
        ],
        ["text": "", "menuType": MenuType.Twocolumn.rawValue, "color": "", "submenus": [
            ["text": "Design Patterns"], ["text": "API"], ["text": "NoSQL"],
            ["text": "Platform"], ["text": "Cloud"]
        ]
        ]
    ]
    
    static let DEFAULT_PROFILE = [
        "person.fill", "username", "user@info.com"
    ]
    static let DEFAULT_PREVIEW = [
        "Show Preview Button", "doc.text.viewfinder"
    ]
    static let DEFAULT_INDICATOR = [
        "Loding Indicator", "circle.dashed", "lineScaling"
    ]
    static let DEFAULT_CATEGORY = [
        "Book Category", "rectangle.3.offgrid", "Swift", "PHP", "SQL"
    ]
}


