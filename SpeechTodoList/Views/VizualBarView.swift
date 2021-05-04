//
//  VizualBarView.swift
//  SpeechTodoList
//
//  Created by Vadim Zahariev on 3.05.21.
//

import SwiftUI

struct VizualBarView: View {
    var value: CGFloat
    let numberOfSamples: Int = 30
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom))
                .frame(width: (UIScreen.main.bounds.width - CGFloat(numberOfSamples) * 10) / CGFloat(numberOfSamples), height: value)
        }
    }
    
    
}
