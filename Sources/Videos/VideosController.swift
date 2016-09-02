import UIKit
import Cartography
import Photos
import AVKit

class VideosController: UIViewController, UICollectionViewDataSource,
  UICollectionViewDelegateFlowLayout, VideoBoxDelegate {

  lazy var gridView: GridView = self.makeGridView()
  lazy var videoBox: VideoBox = self.makeVideoBox()
  lazy var infoLabel: UILabel = self.makeInfoLabel()

  var items: [Video] = []
  let library = VideosLibrary()
  let once = Once()

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    once.run {
      library.reload()
      items = library.items
      gridView.collectionView.reloadData()
    }
  }

  // MARK: - Setup

  func setup() {
    view.addSubview(gridView)
    gridView.translatesAutoresizingMaskIntoConstraints = false

    [videoBox, infoLabel].forEach {
      self.gridView.bottomView.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    constrain(gridView) {
      gridView in

      gridView.edges == gridView.superview!.edges
    }

    constrain(videoBox, infoLabel) {
      videoBox, infoLabel in

      videoBox.width == 48
      videoBox.height == 48
      videoBox.centerY == videoBox.superview!.centerY
      videoBox.left == videoBox.superview!.left + 16

      infoLabel.centerY == infoLabel.superview!.centerY
      infoLabel.left == videoBox.right + 11
      infoLabel.right == infoLabel.superview!.right - 50
    }

    gridView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), forControlEvents: .TouchUpInside)
    gridView.doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), forControlEvents: .TouchUpInside)

    gridView.collectionView.dataSource = self
    gridView.collectionView.delegate = self
    gridView.collectionView.registerClass(VideoCell.self, forCellWithReuseIdentifier: String(VideoCell.self))

    gridView.arrowButton.updateText("ALL VIDEOS")
    gridView.arrowButton.arrow.hidden = true
  }

  // MARK: - Action

  func closeButtonTouched(button: UIButton) {
    EventHub.shared.close?()
  }

  func doneButtonTouched(button: UIButton) {
    EventHub.shared.doneWithVideos?()
  }

  // MARK: - UICollectionViewDataSource

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    gridView.emptyView.hidden = !items.isEmpty
    return items.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(VideoCell.self), forIndexPath: indexPath)
      as! VideoCell
    let item = items[indexPath.item]

    cell.configure(item)
    cell.frameView.label.hidden = true
    configureFrameView(cell, indexPath: indexPath)

    return cell
  }

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

    let size = (collectionView.bounds.size.width - (Config.Grid.Dimension.columnCount - 1) * Config.Grid.Dimension.cellSpacing)
      / Config.Grid.Dimension.columnCount
    return CGSize(width: size, height: size)
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let item = items[indexPath.item]

    if let selectedItem = Cart.shared.video where selectedItem == item {
      Cart.shared.video = nil
    } else {
      Cart.shared.video = item
    }

    refreshView()
    configureFrameViews()
  }

  func configureFrameViews() {
    for case let cell as VideoCell in gridView.collectionView.visibleCells() {
      if let indexPath = gridView.collectionView.indexPathForCell(cell) {
        configureFrameView(cell, indexPath: indexPath)
      }
    }
  }

  func configureFrameView(cell: VideoCell, indexPath: NSIndexPath) {
    let item = items[indexPath.item]

    if let selectedItem = Cart.shared.video where selectedItem == item {
      cell.frameView.g_fadeIn()
    } else {
      cell.frameView.alpha = 0
    }
  }

  // MARK: - VideoBoxDelegate

  func videoBoxDidTap(videoBox: VideoBox) {
    Cart.shared.video?.fetchPlayerItem { item in
      guard let item = item else { return }

      Dispatch.main {
        let controller = AVPlayerViewController()
        let player = AVPlayer(playerItem: item)
        controller.player = player

        self.presentViewController(controller, animated: true) {
          player.play()
        }
      }
    }
  }

  // MARK: - View

  func refreshView() {
    if let selectedItem = Cart.shared.video {
      videoBox.imageView.g_loadImage(selectedItem.asset)
    } else {
      videoBox.imageView.image = nil
    }

    let hasVideoSelected = (Cart.shared.video != nil)
    gridView.doneButton.enabled = hasVideoSelected
    videoBox.hidden = !hasVideoSelected
    infoLabel.hidden = !hasVideoSelected
  }

  // MARK: - Controls

  func makeGridView() -> GridView {
    let view = GridView()
    
    return view
  }

  func makeVideoBox() -> VideoBox {
    let videoBox = VideoBox()
    videoBox.hidden = true
    videoBox.delegate = self

    return videoBox
  }

  func makeInfoLabel() -> UILabel {
    let label = UILabel()
    label.textColor = UIColor.whiteColor()
    label.font = Config.Font.Text.regular.fontWithSize(12)
    label.text = "FIRST 15 SECONDS"
    label.hidden = true

    return label
  }
}
