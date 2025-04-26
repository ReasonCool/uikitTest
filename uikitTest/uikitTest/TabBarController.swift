//
//  TabBarController.swift
//  uikitTest
//
//  Created by 智偉曾 on 2025/4/23.
//
import UIKit
// 配置 TabBarController
class TabBarController: UITabBarController {
   override func viewDidLoad() {
       super.viewDidLoad()
       setupTabs()
   }

   private func setupTabs() {
       // 创建第一个视图控制器
       let firstVC = SelectScreen()
       let firstNav = UINavigationController(rootViewController: firstVC)
       firstNav.tabBarItem = UITabBarItem(
           title: "Home",
           image: UIImage(systemName: "house"),
           selectedImage: UIImage(systemName: "house.fill")
       )

       // 创建第二个视图控制器
       let secondVC = FavouriteScreen()
       let secondNav = UINavigationController(rootViewController: secondVC)
       secondNav.tabBarItem = UITabBarItem(
           title: "Settings",
           image: UIImage(systemName: "gear"),
           selectedImage: UIImage(systemName: "gear.circle.fill")
       )

       let webCanVC = WebCan()
       let webCanNav = UINavigationController(rootViewController: webCanVC)
       webCanNav.tabBarItem = UITabBarItem(
           title: "webCan",
           image: UIImage(systemName: "web.camera"),
           selectedImage: UIImage(systemName: "web.camera.fill")
       )

       // 设置标签栏控制器
       viewControllers = [webCanNav,firstNav, secondNav]

       // 自定义标签栏外观
       tabBar.tintColor = .systemBlue
       tabBar.unselectedItemTintColor = .gray
       tabBar.backgroundColor = .systemBackground
   }
}
