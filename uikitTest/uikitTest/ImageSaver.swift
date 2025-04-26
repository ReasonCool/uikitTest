//
//  ImageSaver.swift
//  uikitTest
//
//  Created by 智偉曾 on 2025/4/24.
//

import UIKit

enum SaveError: Error {
    case directoryCreationFailed
    case imageConversionFailed
    case fileWriteError(underlyingError: Error)
}
class ImageSaver {
    // 定义基础目录路径
    private let baseDirectory: URL = {
        let fileManager = FileManager.default

        let loadDirectory  =  fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            .first
        let baseDir:URL =  loadDirectory!.appendingPathComponent(
            "loadImage",
            isDirectory: true
        )

        return baseDir
    }()

    // 初始化时检查目录
    init() {
        print("baseDirectory\(baseDirectory)")
        createDirectoryIfNeeded()
    }
    // 图片缩放核心方法
        func scaleImageToScreenWidth(image: UIImage) -> UIImage? {
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

    // 创建目录核心方法
    private func createDirectoryIfNeeded() {
        do {
            try FileManager.default.createDirectory(
                at: baseDirectory,
                withIntermediateDirectories: true,
                attributes: [.protectionKey: FileProtectionType.complete]
            )
        } catch {
            print("目录创建失败: \(error.localizedDescription)")
        }
    }

    // 保存图片主方法
    func saveImage(_ image: UIImage, fileName: String) -> Result<URL, Error> {
        // 生成最终文件路径
        let filePath = baseDirectory.appendingPathComponent(fileName)

        // 转换图片数据
        guard let imageData = image.pngData() ?? image.jpegData(compressionQuality: 0.9) else {
            return .failure(NSError(domain: "ImageConversionError", code: 1001, userInfo: nil))
        }

        // 执行保存操作
        do {
            try imageData.write(to: filePath)
            return .success(filePath)
        } catch {
            return .failure(error)
        }
    }

    // 带自动文件名的保存方法
    func saveImageWithAutoNaming(_ image: UIImage) -> Result<URL, Error> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmssSSS"
        let fileName = "IMG_\(dateFormatter.string(from: Date())).jpg"
        return saveImage(image, fileName: fileName)
    }
}

// 扩展功能：增加文件管理方法
extension ImageSaver {
    // 获取目录内所有文件
    func getAllSavedFiles() -> [URL] {
        do {
            return try FileManager.default.contentsOfDirectory(
                at: baseDirectory,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            )
        } catch {
            print("获取文件列表失败: \(error)")
            return []
        }
    }

    // 删除指定文件
    func deleteFile(at url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            print("删除文件失败: \(error)")
            return false
        }
    }

    // 获取目录信息
    func getDirectoryInfo() -> ( Int) {
        let files = getAllSavedFiles()
//        let totalSize = files.reduce(0) {
//            (try? \$1.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0 + \$0
//        }
        return (files.count)
    }
    // 加載單個圖片
        func loadImage(from url: URL) -> UIImage? {
            do {
                // 驗證檔案存在性
                guard FileManager.default.fileExists(atPath: url.path) else {
                    print("檔案不存在: \(url.lastPathComponent)")
                    return nil
                }

                // 讀取圖片數據
                let imageData = try Data(contentsOf: url)

                // 轉換為 UIImage
                guard let image = UIImage(data: imageData) else {
                    print("圖片格式不支援: \(url.lastPathComponent)")
                    return nil
                }

                return image

            } catch {
                print("讀取失敗: \(error.localizedDescription)")
                return nil
            }
        }
}





