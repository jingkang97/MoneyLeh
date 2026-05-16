//
//  Receipt.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 16/5/26.
//

import SwiftUI

struct ReceiptPreviewSheet: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView([.horizontal, .vertical]) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width)
                }
            }
            .navigationTitle("Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {  dismiss() }
                }
            }
        }
    }
}
