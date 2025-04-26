//
//  ViewController.swift
//  uikitTest
//
//  Created by 智偉曾 on 2025/4/23.
//

import UIKit

import Photos

class SelectScreen: UIViewController {
    private let tableView = UITableView()
    private let loadingView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private var catInfos:[catInfo] = []
    private var imageCache = NSCache<NSURL, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        startLoading()
        fetchData()

    }
    // 根据内存警告自动清理
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        imageCache.removeAllObjects()
    }
    private func setupUI(){
        view.backgroundColor = .white
               title = "show Cat Image"

               // 配置表格视图
               tableView.delegate = self
               tableView.dataSource = self
//               tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // 注册自定义单元格
               tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: ImageTableViewCell.identifier)

               // 布局表格
               tableView.translatesAutoresizingMaskIntoConstraints = false
               view.addSubview(tableView)

               NSLayoutConstraint.activate([
                   tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                   tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                   tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
               ])
        // 配置加载视图
                loadingView.backgroundColor = UIColor(white: 0, alpha: 0.5)
                activityIndicator.color = .white

                loadingView.translatesAutoresizingMaskIntoConstraints = false
                activityIndicator.translatesAutoresizingMaskIntoConstraints = false

                view.addSubview(loadingView)
                loadingView.addSubview(activityIndicator)

                NSLayoutConstraint.activate([
                    loadingView.topAnchor.constraint(equalTo: view.topAnchor),
                    loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                    activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
                    activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
                ])
    }
    // 网络请求
       private func fetchData() {
           guard let url = URL(string: "https://api.thecatapi.com/v1/images/search?limit=10") else {
               print("Invalid URL")
               return
           }

           URLSession.shared.dataTask(with: url) {
 [weak self] data,
 response,
 error in
               guard let self = self else { return }

               if let error = error {
                   print("Error: \(error.localizedDescription)")
                   return
               }

               guard let data = data else {
                   print("No data received")
                   return
               }

               do {
                   let decodedData = try JSONDecoder().decode(
                    [catInfo].self,
                    from: data
                   )
                    DispatchQueue.main.async {
                       self.catInfos = decodedData
                        self.stopLoading()
                        self.tableView.reloadData()
                    }
               } catch {
                   print("Decoding error: \(error)")
               }
           }.resume()
       }


    // MARK: - 错误处理
        private func showError(message: String) {
            DispatchQueue.main.async {
                self.stopLoading()

                let alert = UIAlertController(
                    title: "错误",
                    message: message,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "重试", style: .default) { _ in
                    self.startLoading()
                    self.fetchData()
                })
                alert.addAction(UIAlertAction(title: "取消", style: .cancel))

                self.present(alert, animated: true)
            }
        }
    // MARK: - 加载控制
        private func startLoading() {
            loadingView.isHidden = false
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
        }

        private func stopLoading() {
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }
        }
    // MARK: - 通用提示方法
       private func showAlert(title: String, message: String?) {
           DispatchQueue.main.async {
               let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "确定", style: .default))
               self.present(alert, animated: true)
           }
       }
    // MARK: - 保存到系统相册
        private func saveToPhotoLibrary(image: UIImage) {
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.imageSaveCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
                case .denied, .restricted:
                    self.showSettingsAlert()
                case .notDetermined, .limited:
                    break  // 不会执行到这里
                @unknown default:
                    break
                }
            }
        }
    // 保存完成回调
       @objc private func imageSaveCompletion(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
           if let error = error {
               showAlert(title: "保存失败", message: error.localizedDescription)
           } else {
               showAlert(title: "保存成功", message: "图片已保存到系统相册")
           }
       }
    // MARK: - 保存到本地文件

    // MARK: - 权限提示
        private func showSettingsAlert() {
            let alert = UIAlertController(
                title: "需要相册权限",
                message: "请在设置中开启相册访问权限",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            })

            alert.addAction(UIAlertAction(title: "取消", style: .cancel))

            present(alert, animated: true)
        }
}
extension SelectScreen:  UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let cell = tableView.dequeueReusableCell(
               withIdentifier: ImageTableViewCell.identifier,
               for: indexPath
           ) as? ImageTableViewCell else {
               return UITableViewCell()
           }

        let item = catInfos[indexPath.row]

           // 加载占位图
           cell.configure(with: UIImage(systemName: "photo"))

           // 异步加载图片
           downloadImage(url: item.imageUrl) { image in
               DispatchQueue.main.async {
                   if let currentIndexPath = tableView.indexPath(for: cell),
                      currentIndexPath == indexPath {
                       cell.configure(with: image)
                   }
               }
           }

           return cell
       }
    // 修改后的图片下载方法
        private func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
            if let cachedImage = imageCache.object(forKey: url as NSURL) {
                completion(cachedImage)
                return
            }

            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let self = self else { return }

                if let error = error {
                    print("图片下载失败: \(error)")
                    completion(nil)
                    return
                }

                guard let data = data, let originalImage = UIImage(data: data) else {
                    completion(nil)
                    return
                }

                // 在后台线程处理图片缩放
                DispatchQueue.global(qos: .userInitiated).async {
                    let scaledImage = self.scaleImageToScreenWidth(image: originalImage)

                    // 缓存处理后的图片
                    if let scaledImage = scaledImage {
                        self.imageCache.setObject(scaledImage, forKey: url as NSURL)
                    }

                    DispatchQueue.main.async {
                        completion(scaledImage)
                    }
                }
            }.resume()
        }
    // 图片缩放核心方法
        private func scaleImageToScreenWidth(image: UIImage) -> UIImage? {
            let screenWidth = UIScreen.main.bounds.width
            let scaleRatio = screenWidth / image.size.width
            let newHeight = image.size.height * scaleRatio

            let size = CGSize(width: screenWidth, height: newHeight)

            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            image.draw(in: CGRect(origin: .zero, size: size))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return scaledImage
        }


}
extension SelectScreen: UITableViewDelegate  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catInfos.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = imageCache.object(forKey: catInfos[indexPath.row].imageUrl as NSURL) else {
            return 200 // 默认高度
        }
        return image.size.height + 16 // 上下边距
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)
        let catInfo = catInfos[indexPath.row]
        print("Selected todo ID: \(catInfo.id)")
        let item = catInfos[indexPath.row]

               // 获取缓存图片
               guard let image = imageCache.object(forKey: item.imageUrl as NSURL) else {
                   showAlert(title: "提示", message: "图片尚未加载完成")
                   return
               }

               // 弹出保存选项菜单
               let alert = UIAlertController(title: "保存图片", message: nil, preferredStyle: .actionSheet)

               // 保存到相册
               alert.addAction(UIAlertAction(title: "保存到相册", style: .default) { _ in
                   self.saveToPhotoLibrary(image: image)
               })

               // 保存到文件系统
               alert.addAction(
UIAlertAction(title: "保存到本地文件", style: .default) { _ in
                   let imageSaver = ImageSaver()

    let result = imageSaver.saveImage(image, fileName:item.id )
                   switch result {
                   case .success(let fileURL):
                       self.showAlert(
                        title: "保存成功",
                        message: "文件路径: \(fileURL.path)"
                       )
                   case .failure(let error):
                       self.showAlert(
                        title: "保存失败",
                        message: error.localizedDescription
                       )
                   }

               })

               alert.addAction(UIAlertAction(title: "取消", style: .cancel))

               present(alert, animated: true)

       }
}

