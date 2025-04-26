//
//  ImageTableViewCell.swift
//  uikitTest
//
//  Created by 智偉曾 on 2025/4/24.
//

import UIKit

// 自定义单元格
class ImageTableViewCell: UITableViewCell {
    static let identifier = "ImageTableViewCell"

    // 图片视图配置
    private let cellImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(cellImageView)

        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with image: UIImage?) {
        cellImageView.image = image

        // 根据屏幕宽度计算图片高度
        if let image = image {
            let screenWidth = UIScreen.main.bounds.width
            let ratio = screenWidth / image.size.width
            let scaledHeight = image.size.height * ratio

            // 设置图片视图高度约束
            cellImageView.heightAnchor.constraint(equalToConstant: scaledHeight).isActive = true
        }
    }
}
