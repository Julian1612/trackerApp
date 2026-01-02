//
//  HeatmapGridView.swift
//  void.
//
//  Created by Julian Schneider on 02.01.26.
//

import SwiftUI

struct HeatmapGridView: View {
    let data: [Double]
    // 20 Spalten für die Darstellung von ca. 200 Tagen
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 20)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<data.count, id: \.self) { index in
                HeatmapTile(score: data[index])
            }
        }
        .padding()
    }
}
