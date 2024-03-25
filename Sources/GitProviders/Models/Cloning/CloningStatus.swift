//
//  CloningStatus.swift
//  
//
//  Created by Joseph Hinkle on 5/14/21.
//
import SwiftGit2
import SwiftUI

final class CloningStatus: ObservableObject {
    @Published var status: (
        repository: Repository?,
        remoteUrl: String?,
        completedObjects: Int?,
        totalObjects: Int?,
        message: String?
    )?
    
    @ViewBuilder
    var statusOverlay: some View {
        if let status = self.status {
            if let repository = status.repository {
                ProgressView("Success")
            } else if status.repository == nil {
                ProgressView("Failed\(status.message != nil ? " " + (status.message ?? "") : "")")
            } else if let completedObjects = status.completedObjects, let totalObjects = status.totalObjects {
                ProgressView("Cloning...(\(completedObjects)/\(totalObjects)) objects")
            } else {
                ProgressView("Cloning...")
            }
        }
    }
}
