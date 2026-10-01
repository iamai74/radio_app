import Foundation
import RadioBrowserAPI
import Storage

struct CodecAdapter: CodecEntity {
    let name: String
    let stationCount: Int

    init(from codec: some Codec) {
        self.name = codec.name
        self.stationCount = codec.stationCount
    }
}
