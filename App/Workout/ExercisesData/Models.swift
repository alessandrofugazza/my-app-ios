import Foundation

struct ExerciseDraft: Identifiable {
    var name: String
    var movementType: EMovementType?
    var muscle: EMuscle?
    var singleSide: ESide?
    var sideSplit: Bool?
    var id: String {
        let key = "uuid_\(name)"
        if let savedUUID = UserDefaults.standard.string(forKey: key) {
            return savedUUID
        } else {
            let newUUID = UUID().uuidString
            UserDefaults.standard.set(newUUID, forKey: key)
            return newUUID
        }
    }
    
}

struct Exercise: Identifiable {
    var name: String
    var movementType: EMovementType?
    var muscle: EMuscle?
    var side: ESide?
    var draftId: String = ""
    
    var id = UUID()
}
