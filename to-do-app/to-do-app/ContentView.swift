import SwiftUI

// Görev yapısı
struct TaskItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool
}

struct ContentView: View {
    @State private var tasks = [TaskItem]()
    @State private var newTask = ""
    
    // Onboarding kontrolü
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @AppStorage("hasAddedDummyTasks") var hasAddedDummyTasks = false

    var body: some View {
        if hasSeenOnboarding {
            mainView
                .onAppear {
                    if !hasAddedDummyTasks {
                        tasks.append(contentsOf: [
                            TaskItem(title: "İlk görevini ekle!", isDone: false),
                            TaskItem(title: "Bir görevi tamamla!", isDone: false),
                            TaskItem(title: "Görevlerini düzenli takip et!", isDone: false)
                        ])
                        hasAddedDummyTasks = true
                    }
                }
        } else {
            OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
        }
    }

    // Asıl görev ekranı
    var mainView: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Yeni görev gir", text: $newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            addTask()
                        }

                    Button("Ekle") {
                        addTask()
                    }
                }
                .padding()

                List {
                    ForEach(tasks) { task in
                        HStack {
                            Text(task.title)
                                .strikethrough(task.isDone)
                                .foregroundColor(task.isDone ? .gray : .primary)

                            Spacer()
                            TaskDoneButton(isDone: task.isDone) {
                                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                    tasks[index].isDone.toggle()
                                }
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                tasks[index].isDone.toggle()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Görevler")
        }
    }

    // Yeni görev ekleme işlemi
    func addTask() {
        if !newTask.isEmpty {
            tasks.append(TaskItem(title: newTask, isDone: false))
            newTask = ""
        }
    }
}

// Onboarding View
struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var exampleDone = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("📝 To-Do App'e Hoş Geldiniz!")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Görevlerini ekle, takip et ve bitince üstüne tıkla!")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Örnek görev kutusu
            HStack {
                Text("Örnek görev")
                    .strikethrough(exampleDone)
                    .foregroundColor(exampleDone ? .gray : .primary)
                Spacer()
                TaskDoneButton(isDone: exampleDone) {
                    exampleDone.toggle()
                }
            }
            .padding()
            .background(Color.gray.opacity(0.08))
            .cornerRadius(10)
            .padding(.horizontal)

            Spacer()

            Button(action: {
                hasSeenOnboarding = true
            }) {
                Text("Başla 🚀")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct TaskDoneButton: View {
    var isDone: Bool
    var onTap: () -> Void
    @State private var isHovering = false

    var body: some View {
        let circleColor = isDone ? Color.green : (isHovering ? Color.blue.opacity(0.7) : Color.gray.opacity(0.3))
        let circleIcon = isDone ? "checkmark.circle.fill" : "circle"
        Image(systemName: circleIcon)
            .foregroundColor(circleColor)
            .font(.system(size: 24))
            .onTapGesture {
                onTap()
            }
#if os(macOS)
            .onHover { hovering in
                isHovering = hovering
            }
#endif
            .animation(.easeInOut(duration: 0.15), value: isHovering)
    }
}
