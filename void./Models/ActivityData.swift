//
//  ActivityData.swift
//  void.
//
//  Created by Julian Schneider on 02.01.26.
//

import Foundation

struct ActivityDay: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double // Wert zwischen 0.0 und 1.0 für die Graustufe
}
