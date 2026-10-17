import Foundation
import NeedleFoundation
import ImageStorage

/// Dependency contract for the ImageStorage container.
protocol ImageStorageDependency: Dependency {
    var imageStorage: ImageStorage.ImageStorageProtocol { get }
}

/// Container for the ImageStorage package.
final class ImageStorageComponent: Component<ImageStorageDependency> {

    var imageStorage: ImageStorage.ImageStorageProtocol {
        dependency.imageStorage
    }
}
