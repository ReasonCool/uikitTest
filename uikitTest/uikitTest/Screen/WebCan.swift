//
//  WebCan.swift
//  uikitTest
//
//  Created by 智偉曾 on 2025/4/25.
//

import UIKit

class WebCan: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView:UIImageView = UIImageView()
        view.addSubview(imageView)
//        imageView.frame = CGRect(x: 100, y: 100, width: 300, height: 300)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])




        let streamer = MJPEGStreamer(imageView: imageView)
        let url = URL(string: "https://cctv-ss04.thb.gov.tw:443/T14A-006K+950")!
         streamer.startStream(url: url)
    }
}


//import UIKit
//import WebKit
//
//class WebCan: UIViewController, WKNavigationDelegate {
//    var webView: WKWebView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupWebView()
//        loadURL()
//    }
//
//    func setupWebView() {
//        webView = WKWebView()
//        webView.navigationDelegate = self
//        view.addSubview(webView)
//       // webView.frame = CGRect(x: 30, y: 30, width: 100, height:100)
//        webView.translatesAutoresizingMaskIntoConstraints = false
//        // Auto Layout
//        NSLayoutConstraint.activate([
//            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//
//    func loadURL() {
//        guard let url = URL(string: "http://cctv-ss04.thb.gov.tw/T14A-006K+950") else { return }
//        webView.load(URLRequest(url: url))
//    }
//}
//



//import AVKit
//import AVFoundation
//import UIKit
//import AVKit
//
//class WebCan: UIViewController   {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let originalURL = "http://cctv-ss04.thb.gov.tw/T14A-006K+950"
//        guard let urlStr = originalURL.addingPercentEncoding(
//            withAllowedCharacters:.urlFragmentAllowed) else{
//            return
//        }
//
//        print(urlStr)
//
//        guard let url = URL(string: urlStr) else {
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//               if let error = error {
//                   print("Error fetching image: \(error.localizedDescription)")
//                   return
//               }
//
//               guard let data = data, let image = UIImage(data: data) else {
//                   print("Failed to convert data to image")
//                   return
//               }
//
//               // Update UI on the main thread
//               DispatchQueue.main.async {
//                   let imageView = UIImageView(image: image)
//                   imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
//                   // Add the imageView to your view hierarchy
//                   self.view.addSubview(imageView)
//               }
//           }
//           task.resume()
//
//    }
//}
//


//    var playerViewController: AVPlayerViewController!
//
//        override func viewDidLoad() {
//            super.viewDidLoad()
//
//            // 替换成你的视频流 URL
//
////            guard let url = URL(string: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8") else { return }
//
//            let originalURL = "http://cctv-ss04.thb.gov.tw/T14A-006K+950"
//            guard let urlStr = originalURL.addingPercentEncoding(
//                withAllowedCharacters:.urlFragmentAllowed) else{
//                return
//            }
//
//            print(urlStr)
//
//            guard let url = URL(string: urlStr) else {
//                return
//            }
//
//            let player = AVPlayer(url: url)
//
//            //player.automaticallyWaitsToMinimizeStalling = false
//            player.currentItem?.preferredForwardBufferDuration = 5 // 预缓冲 5 秒
//            playerViewController = AVPlayerViewController()
//            playerViewController.player = player
//            // 添加播放器视图
//            addChild(playerViewController)
//            view.addSubview(playerViewController.view)
//            playerViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
//
//            // 开始播放
//            player.play()
//        }



//    // 加载本地视频文件（需确保文件已加入项目）
//    guard let url = Bundle.main.url(forResource: "video", withExtension: "mp4") else { return }

//import UIKit
//import AVKit
//
//class WebCan: UIViewController  {
//
//    var player: AVPlayer?
//    var playerLayer: AVPlayerLayer?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        setupPlayer()
//    }
//    private func setupPlayer() {
//        let originalURL = "https://cctv-ss04.thb.gov.tw:443/T14A-006K+950"
//        guard let urlStr = originalURL.addingPercentEncoding(
//                        withAllowedCharacters:.urlFragmentAllowed) else{
//                        return
//                    }
//        print(urlStr)
//        guard let url = URL(string: urlStr) else { return }
//     //  guard let url = URL(string: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8") else { return }
//         player = AVPlayer(url: url)
//
//        playerLayer = AVPlayerLayer(player: player)
//        playerLayer?.frame = view.bounds
//        view.layer.addSublayer(playerLayer!)
////
//        // 监听播放状态
//        player?.currentItem?
//            .addObserver(
//                self,
//                forKeyPath: "status",
//                options: .new,
//                context: nil
//            )
//
//
//    }
//
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "status" {
//            switch player?.status{
//            case .failed:
//                print("player status: failed" )
//            case .readyToPlay:
//                print("player status: readyToPlay" )
//                player!.play()
//            case .unknown:
//                print("player status: unknown" )
//            case .none:
//                print("player status: none" )
//
//            case .some(_):
//                print("player status: some" )
//
//            }
//
//
//        }
//    }
//}




