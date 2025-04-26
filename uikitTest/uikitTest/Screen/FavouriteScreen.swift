//
//  SencondViewController.swift
//  uikitTest
//
//  Created by 智偉曾 on 2025/4/23.
//
import UIKit

class FavouriteScreen: UIViewController {
    private let tableView = UITableView()
    private let loadingView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let imageSaver = ImageSaver()
    private var catImages:[UIImage] = []
    private var imageURLs:[URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()


       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startLoading()
        fetchImages()
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


    private func fetchImages(){
        imageURLs  = imageSaver.getAllSavedFiles()
        catImages.removeAll()
        imageURLs.forEach { url in
             //取得圖片內容
            if let image = imageSaver.loadImage(from: url){
                //自動縮放
                if let scaleImage = imageSaver.scaleImageToScreenWidth(image: image) {
                    catImages.append(scaleImage)
                }
            }
        }
        stopLoading()
        print("catImages count = \(catImages.count)")
        tableView.reloadData()

    }
    private func deleteImageWithURL(url:URL){
        if   imageSaver.deleteFile(at: url){
            let alert = UIAlertController(title: "刪除图片", message: nil, preferredStyle: .actionSheet)
            // 保存到相册
            alert.addAction(UIAlertAction(title: "成功", style: .default) { _ in
                self.fetchImages()
            })
            present(alert, animated: true)
        }else{
            self.showAlert(title: "刪除圖片", message: "失敗")
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
}
extension FavouriteScreen: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image:UIImage = catImages[indexPath.row]
        return image.size.height + 16 // 上下边距

    }
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        //TODO:詢問是否刪除
        //TODO:刪除
            //imageURLs
        // 弹出保存选项菜单
        let alert = UIAlertController(title: "刪除图片", message: nil, preferredStyle: .actionSheet)

        // 保存到相册
        alert.addAction(UIAlertAction(title: "確定", style: .default) { _ in
            self.deleteImageWithURL(url:self.imageURLs[indexPath.row])
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))

        present(alert, animated: true)
    }

}
extension FavouriteScreen: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catImages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImageTableViewCell.identifier,
            for: indexPath
        ) as? ImageTableViewCell else {
            return UITableViewCell()
        }
        let image:UIImage = catImages[indexPath.row]
        cell.configure(with: image)
        return cell
    }
}
