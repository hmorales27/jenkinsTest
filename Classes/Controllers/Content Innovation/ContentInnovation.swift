/*
 * ContentInnovation
 */

import UIKit
import Cartography

protocol ContentInnovationDelegate: class {
    func contentInnovation(_ manager: ContentInnovation.Manager, shouldShowButton button: UIImage, withText text: String)
}



class ContentInnovation {
    
    class Manager {
        
        enum Status {
            case notUpdated
            case updating
            case updateFailed
            case updateComplete
        }
        
        var delegate: ContentInnovationDelegate?
        var article: Article?
        
        var status: Status = .notUpdated
        
        var task: URLSessionDataTask?
        
        var available: Bool = false
        var response: CIResponse?
        
        var numberOfWidgets: Int {
            if let response = self.response {
                return response.widgetModel.count
            }
            return 0
        }
        
        init() {
            
        }
        
        func update(article _article: Article) {
            
            reset()
            
            article = _article
            status = .updating
            
            if let request = JBSMURLRequest.V1.ContentInnovationRequest(article: _article) {
                let session = URLSession(configuration: URLSessionConfiguration.default)
                session.dataTask(with: request, completionHandler: { (responseData, response, responseError) in
                    
                    guard let data = responseData else {
                        self.status = .updateFailed
                        return
                    }
                    
                    do {
                        
                        if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
                            let response = CIResponse(metadata: json)
                            if response.articlePii == self.article?.articleInfoId {
                                self.response = response
                                self.status = .updateComplete
                                return
                            }
                        }
                        
                    } catch let error as NSError {
                        log.error(error.localizedDescription)
                    }
                    
                    self.status = .updateFailed
                    
                }).resume()
            }
            
        }
        
        func updateExternal() {
            guard let response = self.response else {
                return
            }
            
            if response.widgetModel.count > 0 {
                
                if response.widgetModel.count == 1 {
                    if let image = UIImage(contentsOfFile: CachesDirectoryPath + "appimages/" + "multiplewidgetimage.png") {
                        delegate?.contentInnovation(self, shouldShowButton: image, withText: response.widgetFeatureMessage)
                    } else {
                        log.error("Unable to get Multi Widget Image")
                    }
                } else {
                    let widget = self.response!.widgetModel[0]
                    if widget.widgetImageUrl != "" {
                        let components = widget.widgetImageUrl.components(separatedBy: "/")
                        if let lastComponent = components.last {
                            if let image = UIImage(contentsOfFile: CachesDirectoryPath + "appimages/" + lastComponent) {
                                delegate?.contentInnovation(self, shouldShowButton: image, withText: widget.widgetName)
                                return
                            }
                        }
                    }
                }
            }
        }
        
        func reset() {
            status = .notUpdated
            article = nil
        }
        
    }
    
    class Button {
        
    }
    
    class Response {
        
    }
}
