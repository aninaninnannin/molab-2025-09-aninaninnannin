import SwiftUI
import UIKit

struct AssetImage: View {
    let name: String
    var body: some View {
        if let ui = UIImage(named: name) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "shippingbox.fill")
                .resizable()
                .scaledToFit()
                .padding(20)
        }
    }
}
