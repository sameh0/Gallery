import UIKit
import Cartography
import Photos

extension UIViewController {

  func g_addChildController(controller: UIViewController) {
    addChildViewController(controller)
    view.addSubview(controller.view)
    controller.didMoveToParentViewController(self)

    controller.view.translatesAutoresizingMaskIntoConstraints = false

    constrain(controller.view) { view in
      view.edges == view.superview!.edges
    }
  }

  func g_removeFromParentController() {
    willMoveToParentViewController(nil)
    view.removeFromSuperview()
    removeFromParentViewController()
  }
}

extension UIView {

  func g_addShadow() {
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize(width: 0, height: 1)
    layer.shadowRadius = 1
  }

  func g_addRoundBorder() {
    layer.borderWidth = 1
    layer.borderColor = Config.Grid.FrameView.borderColor.CGColor
    layer.cornerRadius = 3
    clipsToBounds = true
  }

  func g_fadeIn() {
    UIView.animateWithDuration(0.1) {
      self.alpha = 1.0
    }
  }
}

extension UIScrollView {

  func g_scrollToTop() {
    setContentOffset(CGPoint.zero, animated: false)
  }
}

extension UIImageView {

  func g_loadImage(asset: PHAsset) {
    guard frame.size != CGSize.zero
      else {
      image = Bundle.image("gallery_placeholder")
      return
    }

    if tag == 0 {
      image = Bundle.image("gallery_placeholder")
    } else {
      PHImageManager.defaultManager().cancelImageRequest(PHImageRequestID(tag))
    }

    let options = PHImageRequestOptions()

    let id = PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: frame.size,
                                                         contentMode: .AspectFill, options: options)
    { [weak self] image, _ in

      self?.image = image
    }

    tag = Int(id)
  }
}

extension Array {

  mutating func g_moveToFirst(index: Int) {
    guard index != 0 && index < count else { return }

    let item = self[index]
    removeAtIndex(index)
    insert(item, atIndex: 0)
  }
}