import UIKit
@main final class UyQuyenUngDung: UIResponder, UIApplicationDelegate {
    var cuaSo: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let w = UIWindow(frame: UIScreen.main.bounds)
        w.rootViewController = UINavigationController(rootViewController: ManHinhChinh())
        w.tintColor = .systemBlue
        w.makeKeyAndVisible(); cuaSo = w
        return true
    }
}
