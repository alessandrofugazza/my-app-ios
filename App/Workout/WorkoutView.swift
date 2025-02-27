import SwiftUI

struct WorkoutView: View {
    
    @EnvironmentObject var exerciseDrafts: ExerciseDrafts
    @EnvironmentObject var debugExercises: DebugExercisesData
    
    @State var prioritiesPool: [EPriority] = []
    @State var newExercise: Exercise = Exercise()
    @State var prevExercise: Exercise = Exercise()
    @State var scale: CGFloat = 1.0
    @State var allExercises: [EPriority: [EMechanic: [Exercise]]] = [:]
    @State var flag = false
    @State var randomPriority: EPriority? = nil
    @State var currentMachanic: EMechanic = .isolation
    @State var currentRepetitions: Int = 0
    @State var currentWeight: Int = 0
    
    @State private var isFocusExerciseTimerTriggered = true
    @State private var focusExerciseTimer: Timer?
    
    
    
    func startFocusExerciseTimer() {
        focusExerciseTimer?.invalidate()
        
        focusExerciseTimer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { _ in
            isFocusExerciseTimerTriggered = true
        }
    }
    
    func stopTimer() {
        focusExerciseTimer?.invalidate()
        focusExerciseTimer = nil
    }
    
    func saveExerciseData(repetitions: Int, weight: Int, for id: String) {
        let key = "exercise_\(id)"
        let exerciseData: SavedExerciseData = ["repetitions": repetitions, "weight": weight]
        UserDefaults.standard.set(exerciseData, forKey: key)
    }
    
    func getExerciseData(for id: String) -> SavedExerciseData? {
        let key = "exercise_\(id)"
        return UserDefaults.standard.dictionary(forKey: key) as? SavedExerciseData
    }
    
    func haveCommonMuscles(_ exercise1: Exercise, _ exercise2: Exercise) -> Bool {
        let muscles1 = exercise1.muscles.values.flatMap { $0 }
        let muscles2 = exercise2.muscles.values.flatMap { $0 }
        
        return !Set(muscles1).intersection(Set(muscles2)).isEmpty
    }
    
    private func setUpExercises() -> [EPriority: [EMechanic: [Exercise]]] {
        var exercisesDict: [EPriority: [EMechanic: [Exercise]]] = [:]
        
        for priority in EPriority.allCases {
            exercisesDict[priority] = [:]
            
            for mechanic in EMechanic.allCases {
                var exercises: [Exercise] = []
                
                if let draftsForPriority = exerciseDrafts.exerciseDrafts[priority]?[mechanic] {
                    for draft in draftsForPriority {
                        var newExercise = Exercise(
                            name: draft.name.capitalized,
                            muscles: draft.muscles,
                            draftId: draft.id
                        )
                        
                        if draft.sideType == .split {
                            var newExerciseRight = newExercise
                            var newExerciseLeft = newExercise
                            newExerciseRight.side = .right
                            newExerciseRight.name.append(ESide.right.rawValue)
                            newExerciseLeft.name.append(ESide.left.rawValue)
                            newExerciseLeft.side = .left
                            exercises.append(newExerciseRight)
                            exercises.append(newExerciseLeft)
                        } else {
                            if draft.sideType == .singleFocus {
                                newExercise.side = draft.sideFocus
//                                seems to not be working?
                                newExercise.name.append(draft.sideFocus?.rawValue ?? "Missing side focus")
                            }
                            exercises.append(newExercise)
                        }
                    }
                }
                exercisesDict[priority]?[mechanic] = exercises
            }
        }
        
        return exercisesDict
    }
    
    var body: some View {
        VStack {
            Text(newExercise.name)
                .font(.largeTitle)
                .animation(.default, value: newExercise.id)
            if newExercise.name != "" {
                VStack {
                    RepetitionControlComponentView(currentRepetitions: $currentRepetitions) {
                        saveExerciseData(repetitions: currentRepetitions, weight: currentWeight, for: prevExercise.draftId)
                    }
                    WeightControlComponentView(currentWeight: $currentWeight) {
                        saveExerciseData(repetitions: currentRepetitions, weight: currentWeight, for: prevExercise.draftId)
                    }
                    
                    
                }
            }
            
            
            Divider()
                .padding()
            
            Button(action: {
                if isFocusExerciseTimerTriggered && newExercise.name != "FOCUS" {
                        
                    newExercise.name = "FOCUS"
                    
                    
                } else {
                    if newExercise.name == "FOCUS" {
                        isFocusExerciseTimerTriggered = false
                        startFocusExerciseTimer()
                    }
                    
                    randomPriority = prioritiesPool.randomElement()!
                    currentMachanic = currentMachanic == .compound ? .isolation : .compound
                    
                    repeat {
                        flag = false
                        if let selectedExercise = allExercises[randomPriority!]?[currentMachanic]!.randomElement() {
                            newExercise = selectedExercise
                        }
                        
                        if haveCommonMuscles(newExercise, prevExercise) {
                            flag = true
                            continue
                        }
                    } while flag
                    prevExercise = newExercise
                    
                    let currentExerciseSavedData = getExerciseData(for: newExercise.draftId)
                    currentRepetitions = currentExerciseSavedData?["repetitions"] ?? 0
                    currentWeight = currentExerciseSavedData?["weight"] ?? 0
                    
                }
                withAnimation {
                    scale = 1.1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation {
                        scale = 1.0
                    }
                }
            }) {
                Text("NEXT")
                    .bold()
                    .padding()
                    .foregroundColor(.white)
                    .background(Color(red: 205/255, green: 92/255, blue: 92/255))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white, lineWidth: 2))
                    .scaleEffect(scale)
                
            }
        }
        .onAppear {
            var i = 8
            for priority in EPriority.allCases {
                for _ in 1...i {
                    prioritiesPool.append(priority)
//                    print(priority.rawValue)
                }
                i /= 2
            }
            
            allExercises = setUpExercises()
            prevExercise = Exercise()
            newExercise = Exercise()
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
    }
}
