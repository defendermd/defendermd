
import Foundation

class UploadService {

  var uploadsSession: URLSession!
  var activeUploads: [URLRequest: Upload] = [:]

  func startUpload(_ activityFeed: NSMutableDictionary) {
    // 1
    let upload = Upload(activityFeed: activityFeed)
    // 2
    let requestObject = activityFeed["requestObject"] as! URLRequest
    upload.task = uploadsSession.uploadTask(with: requestObject, from: requestObject.httpBody!)
    // 3
    upload.task!.resume()
    // 4
    upload.isDownloading = true
    // 5
    let requestT = upload.activityFeed["requestObject"] as! URLRequest
    activeUploads[requestT] = upload
  }

  func cancelUpload(_ activityFeed: NSMutableDictionary) {
    if let upload = activeUploads[activityFeed["requestObject"] as! URLRequest]{
      upload.task?.cancel()
      activeUploads[activityFeed["requestObject"] as! URLRequest] = nil
        
      if let indexRemove = upload.activityFeed["index"] as? Int
      {
          for (key, value) in activeUploads
          {
            if let indexExisting = value.activityFeed["index"] as? Int, indexExisting > indexRemove
            {
                print("Next index decrement==\(indexExisting - 1)")
                value.activityFeed["index"] = indexExisting - 1 as AnyObject
                activeUploads[key] = value
            }
            else
            {
                print("Next index not included ==\(value.activityFeed["index"] as! Int) current delete index == \(indexRemove)")
            }
          }
      }
    }
  }
    
    func pauseDownload(_ activityFeed: NSMutableDictionary) {
        guard let upload = activeUploads[activityFeed["requestObject"] as! URLRequest] else { return }
        if upload.isDownloading {
//            upload.task?.cancel(byProducingResumeData: { data in
//                upload.resumeData = data
//            })
            upload.task?.suspend()
            upload.isDownloading = false
        }
    }
    func resumeDownload(_ activityFeed: NSMutableDictionary) {
        guard let upload = activeUploads[activityFeed["requestObject"] as! URLRequest] else { return }
        if upload.resumeData.length != 0 {
            let requestObject = activityFeed["requestObject"] as! URLRequest
            //upload.task = uploadsSession.downloadTask(withResumeData: resumeData)
            upload.task = uploadsSession.uploadTask(with: requestObject, from: upload.resumeData as Data)
        } else {
            let requestObject = activityFeed["requestObject"] as! URLRequest
            upload.task = uploadsSession.uploadTask(with: requestObject, from: requestObject.httpBody!)
        }
        upload.task!.resume()
        upload.isDownloading = true
    }
}
