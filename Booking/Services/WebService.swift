import Foundation
import Combine
import ObjectMapper
import SwiftyJSON

struct WebService {
    static let shared = WebService()
    
    private init(){}
    
    private var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache.shared
        config.waitsForConnectivity = true
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }()
    
    func createPublisher(_ url: URL) -> AnyPublisher<JSON, Error> {
        let publisher = session.dataTaskPublisher(for: url)
            .tryMap({$0.data})
            .decode(type: JSON.self, decoder: decoder)
            .eraseToAnyPublisher()
        return publisher
    }
    
    func createSectionPublisher() -> AnyPublisher<(JSON, JSON, JSON), Error> {
        return Publishers.Zip3(createPublisher(.new),
                               createPublisher(.book(key: SettingService.shared.setting.categoryName)),
                               createPublisher(.book()))
            .eraseToAnyPublisher()
    }
    
    func createMorePublisher(with section: BookSection, key: String? = "", page: Int = 1) -> AnyPublisher<JSON, Error> {
        switch section {
        case .Latest:
            return createPublisher(.new)
        case .Category:
            return createPublisher(.book(key: SettingService.shared.setting.categoryName, with: page))
        case .Random:
            return createPublisher(.book(page: page))
        case .Free:
            return createPublisher(.book(key: key!, with: page))
        }
    }
    
    func download(url: String, title: String , ext: String = ".pdf", completionBlock:@escaping (URL)->()) {
        let remoteURL = URL(string: url)!
        
        let task = session.downloadTask(with: remoteURL) { localURL, urlResponse, error in
            guard let localURL = localURL else { return }
            
            let docURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(title)\(ext)")
            try? FileManager.default.removeItem(at: docURL)
            try! FileManager.default.moveItem(at: localURL, to: docURL)
            
            print("save(\(docURL)")
            completionBlock(docURL)
        }
        
        task.resume()
    }
    
    func fileExists(title: String , ext: String = ".pdf", completionBlock:@escaping (Bool?, URL?)->()) {
        let docURL = FileManager().temporaryDirectory.appendingPathComponent("\(title)\(ext)")
        if FileManager.default.fileExists(atPath: docURL.path) {
            completionBlock(true, docURL)
            return
        }
        
        completionBlock(false, docURL)
    }
}
