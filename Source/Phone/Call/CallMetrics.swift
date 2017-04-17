// Copyright 2016 Cisco Systems Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

struct Feedback {
    var rating: Int
    var comments: String? = nil
    var includeLogs: Bool = false
    
    var metricData: Metric.DataType {
        var data: Metric.DataType = [:]
        
        data["rating"] = String(rating)
        
        if rating == 0 {
            data["declinedRating"] = String(true)
        }
        
        if includeLogs {
            data["log"] = LoggerManager.sharedInstance.getMemoryLogs()
        }
     
        return data
    }
}

class CallMetrics {
        
    private let TestUserEmailDomain = "example.com"
    private let metricsEngine: MetricsEngine
    
    init(authenticator: Authenticator, deviceService: DeviceService) {
        metricsEngine = MetricsEngine(authenticator: authenticator, deviceService: deviceService)
    }
    
    func submit(feedback: Feedback, call: CallModel, deviceUrl: URL) {
        var data: Metric.DataType = [
            "locusId": call.callUrl!,
            "locusTimestamp": call.fullState!.lastActive!,
            "deviceUrl": deviceUrl.absoluteString,
            "participantId": call.myself!.id!,
            "isGroup": !call.isOneOnOne,
            "wmeVersion": MediaEngineWrapper.sharedInstance.WMEVersion
        ]

        data.unionInPlace(feedback.metricData)
        let metric = Metric.genericMetricWithName(Metric.Call.Rating, data: data, environment: MetricsEnvironment.Production)
        metricsEngine.trackMetric(metric)
    }
    
    func reportVideoLicenseActivation() {
        let metric = Metric.incrementMetricWithName(Metric.Call.ActivatingVideo, category: MetricsCategory.generic)
        metricsEngine.trackMetric(metric)
    }
}
