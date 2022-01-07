
import Foundation

class Upload {

  var activityFeed: NSMutableDictionary
  init(activityFeed: NSMutableDictionary) {
    self.activityFeed = activityFeed
  }

  var task: URLSessionDataTask?
  var isDownloading = false
  var resumeData = NSMutableData()
  var progress: Float = 0

}
