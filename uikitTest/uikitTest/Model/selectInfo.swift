//
//  selectInfo.swift
//  uikitTest
//
//  Created by 智偉曾 on 2025/4/23.
//

import UIKit

struct catInfo{
    var id :String
    var url: String
    var width:Int
    var height:Int
    var imageUrl: URL

}

extension catInfo:Identifiable {}

extension catInfo:Decodable {
    enum CodingKeys: CodingKey {
        case id
        case url
        case width
        case height
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.url = try container.decode(String.self, forKey: .url)
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
        if let imageUrl = URL(string: self.url) {
            self.imageUrl  = imageUrl
        }else{
            self.imageUrl = URL(string:"https://cdn2.thecatapi.com/images/9bv.jpg")!

        }

    }
}
