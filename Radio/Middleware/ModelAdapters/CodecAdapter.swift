import Foundation
import RadioBrowserAPI
import Storage

extension CodecRecord {
    init(from codec: some Codec) {
        self.init(name: codec.name, stationCount: codec.stationCount)
    }
}
