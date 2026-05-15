//
//  AppConstants.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import Foundation
enum AppConstants {
    
    enum API {
//<<<<<<< Updated upstream
//        static let baseURL = "http://localhost:3001"
//=======
        static let baseURL = "http://127.0.0.1:3001"
//>>>>>>> Stashed changes
        static let imageBasePath = baseURL + "/images/"
        static let timeout: TimeInterval = 30
    }
}
