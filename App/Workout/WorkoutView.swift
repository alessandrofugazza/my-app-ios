import SwiftUI

struct WorkoutView: View {
    
    @EnvironmentObject var legsExercises: LegsDrafts
    @EnvironmentObject var absExercises: AbsDrafts
    @EnvironmentObject var armsExtExercises: ArmsExtDrafts
    @EnvironmentObject var armsFlexExercises: ArmsFlexDrafts
    @EnvironmentObject var debugExercises: DebugExercisesData
    
    @State var prioritiesPool: [EPriority] = []
    
//    IMPROVE is there really no better way to not initialize
    @State var newExercise: Exercise = Exercise()
    @State var prevExercise: Exercise = Exercise()
    @State var scale: CGFloat = 1.0
    @State var allExercises: [EPriority: [Exercise]] = [:]
    @State var flag = false
    @State var randomPriority: EPriority? = nil
    
    @State var currentRepetitions: Int = 0
    
    func saveRepetitions(_ repetitions: Int, for id: String) {
        let key = "reps_\(id)"
        UserDefaults.standard.set(repetitions, forKey: key)
    }
    
    func getRepetitions(for id: String) -> Int {
        let key = "reps_\(id)"
        return UserDefaults.standard.integer(forKey: key)
    }
    
    
    private func setUpExercises(p1: [ExerciseDraft], p2: [ExerciseDraft], p3: [ExerciseDraft]) -> [EPriority: [Exercise]] {
        var exercisesDict: [EPriority: [Exercise]] = [:]
        let allExercisesDrafts = [p1, p2, p3]
        
        var i = 0
        for priority in EPriority.allCases {
            var exercises: [Exercise] = []
//            REFACTOR this fucking shit
            for draft in allExercisesDrafts[i] {
                var newExercise = Exercise(
                    name: draft.name.capitalized,
                    bodyPart: draft.bodyPart,
                    movementType: draft.movementType, 
                    muscle: draft.muscle,
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
                    if (draft.sideType == .singleFocus) {
                        newExercise.side = draft.sideFocus
                        newExercise.name.append(draft.sideFocus?.rawValue ?? "you forgot to add sidefocus you dumb fuck")
                    }
                    exercises.append(newExercise)
                }
            }
            i+=1
            exercisesDict[priority] = exercises
        }
        return exercisesDict
    }
    
    
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    HStack {
                        Text(newExercise.name)
                            .font(.largeTitle)
//                            .frame(minHeight: 200)
                            
                        VStack {
                            if randomPriority != nil {
                                Text(randomPriority!.rawValue)
                            }  
                            if let muscle = newExercise.muscle {
                                Text(muscle.rawValue)
                                    .animation(.default, value: newExercise.id)
                            } 
                            if let movementType = newExercise.movementType {
                                Text(movementType.rawValue)
                                    .animation(.default, value: newExercise.id)
                            }
                        }
                    }
                    .animation(.default, value: newExercise.id)
                    if (newExercise.name != "") { 
                        HStack {
                            Button(action: {
                                if currentRepetitions > 0 {
                                    currentRepetitions -= 1
                                    saveRepetitions(currentRepetitions, for: newExercise.draftId)
                                }
                            }) {
                                Image(systemName: "minus.circle")
                                    .font(.largeTitle)
                            }
                            
                            
                            Text("\(currentRepetitions) reps")
                                .font(.title)
                                .padding(.horizontal)
                            
                            Button(action: {
                                currentRepetitions += 1
                                saveRepetitions(currentRepetitions, for: newExercise.draftId)
                            }) {
                                Image(systemName: "plus.circle")
                                    .font(.largeTitle)
                            }
                        }
                        .padding()
                    }
                }
            }
            Divider()
                .padding()
            Button(action: {
                repeat {
                    randomPriority = prioritiesPool.randomElement()!
                    flag = false
                    if let selectedExercise = allExercises[randomPriority!]?.randomElement() {
                        newExercise = selectedExercise
                    } 
                    if (newExercise.id == prevExercise.id) {
                        flag = true
                        continue
                    }
                    
                    if (newExercise.bodyPart == prevExercise.bodyPart && newExercise.side == prevExercise.side) {
                        flag = true
                        continue
                        
                    }
                    
                } while (
                    flag == true
                ) 
                prevExercise = newExercise
                currentRepetitions = getRepetitions(for: newExercise.draftId)
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
            }
            .padding()
            .foregroundColor(.white)
            .background(Color(red: 205/255, green: 92/255, blue: 92/255))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white, lineWidth: 2))
            .scaleEffect(scale)
        }
        .onAppear {
            var i = 4
            for priority in EPriority.allCases {
                for _ in 1...i {
                    prioritiesPool.append(priority)
                }
                i/=2
            }
            
            
            allExercises = setUpExercises(
                p1: legsExercises.legsDraftsI + absExercises.absDraftsI + armsExtExercises.armsExtDraftsI + armsFlexExercises.armsFlexDraftsI, 
                p2: legsExercises.legsDraftsII + absExercises.absDraftsII + armsExtExercises.armsExtDraftsII + armsFlexExercises.armsFlexDraftsII, 
                p3: legsExercises.legsDraftsIII + absExercises.absDraftsIII + armsExtExercises.armsExtDraftsIII + armsFlexExercises.armsFlexDraftsIII
            )
            
//            allExercises = setUpExercises(
//                p1: 
//                    debugExercises.dDebugI, 
//                p2: debugExercises.dDebugII, 
//                p3: debugExercises.dDebugIII
//            )
            
            
        }
        
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
    }
}
