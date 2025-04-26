//
//  MJPEGStreamer.swift
//  uikitTest
//
//  Created by 智偉曾 on 2025/4/26.
//

import UIKit
class MJPEGStreamer: NSObject  {
    private var session: URLSession!
    private var dataTask: URLSessionDataTask?
    private var boundary: String?
    private var buffer = Data()
    private var imageView :UIImageView?

     init(imageView:UIImageView) {
        super.init()
        self.imageView = imageView
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }

    func startStream(url: URL) {
        dataTask = session.dataTask(with: url)
        dataTask?.resume()
    }

    func stopStream() {
        dataTask?.cancel()
        buffer = Data()
    }
}

extension MJPEGStreamer: URLSessionDataDelegate {
    // 收到响应头时解析 boundary
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        buffer = Data()
        // 判断是否为 multipart 流
        guard let contentType = (response as? HTTPURLResponse)?.allHeaderFields["Content-Type"] as? String else {
                  completionHandler(.cancel)
                  return
              }
        if  let boundaryRange = contentType.range(of: "boundary=.*?$", options: .regularExpression){
            boundary = String(contentType[boundaryRange].dropFirst("boundary=".count))
                    completionHandler(.allow)
            completionHandler(.allow)
        }
        if  let boundaryRange = contentType.range(of: "image/jpeg", options: .regularExpression){
            //contentType: "image/jpeg"
            // 普通 JPEG 流
            boundary = nil
            completionHandler(.allow)
        }

    }

    // 持续接收数据
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        processBuffer()
    }
}
private extension MJPEGStreamer {
    func processBuffer() {
            if let boundary = boundary {
                // 处理 multipart 流（原有逻辑）
                processMultipartBuffer( )
            } else {
                // 处理连续 JPEG 流（新增逻辑）
                processContinuousJPEGBuffer()
            }
        }
    func processMultipartBuffer() {
            guard let boundary = self.boundary else { return }
            let boundaryPrefix = "--\(boundary)".data(using: .utf8)!

            // 查找边界位置
            while let range = buffer.range(of: boundaryPrefix) {
                // 提取一个完整帧的数据（从上一个边界到当前边界）
                let frameRange = buffer.startIndex..<range.upperBound
                guard let frameEnd = buffer.range(of: boundaryPrefix, options: [], in: range.upperBound..<buffer.endIndex) else { break }

                let frameData = buffer.subdata(in: range.upperBound..<frameEnd.lowerBound)
                processFrameData(frameData)

                // 移除已处理的数据
                buffer.removeSubrange(buffer.startIndex..<frameEnd.upperBound)
            }
        }
    // 处理无分隔符的连续 JPEG 流
        func processContinuousJPEGBuffer() {
            let startMarker = Data([0xFF, 0xD8]) // JPEG 起始标记
            let endMarker = Data([0xFF, 0xD9])   // JPEG 结束标记

            var currentIndex = buffer.startIndex

            while true {
                // 查找起始标记
                guard let startRange = buffer.range(of: startMarker, in: currentIndex..<buffer.endIndex),
                      startRange.lowerBound >= currentIndex else {
                    break
                }

                // 从起始标记开始查找结束标记
                let searchRange = startRange.lowerBound..<buffer.endIndex
                guard let endRange = buffer.range(of: endMarker, in: searchRange) else {
                    break
                }

                // 提取完整的 JPEG 数据（包含起始和结束标记）
                let jpegEndIndex = endRange.upperBound
                let jpegData = buffer.subdata(in: startRange.lowerBound..<jpegEndIndex)

                // 处理 JPEG 帧
                processFrameData(jpegData)

                // 移动索引，继续处理后续数据
                currentIndex = jpegEndIndex
            }

            // 移除已处理的数据
            if currentIndex > buffer.startIndex {
                buffer.removeSubrange(buffer.startIndex..<currentIndex)
            }
        }
    func processFrameData(_ data: Data) {
        // 提取 JPEG 数据（跳过可能的 HTTP Headers）
        guard let jpegRange = data.range(of: Data([0xFF, 0xD8])) else { return }
        let jpegData = data.subdata(in: jpegRange.lowerBound..<data.endIndex)

        // 转换为 UIImage
        if let image = UIImage(data: jpegData) {
            DispatchQueue.main.async {
                // 更新 UI（例如显示在 UIImageView 中）
                guard ((self.imageView?.image = image) != nil) else{
                    return
                }
            }
        }
    }
}




