import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var isListening = false

    var body: some View {
        TabView {
            MainView(isListening: $isListening)
                .tabItem {
                    Image(systemName: "ear")
                    Text("Main")
                }
            
            Text("Upload stuff")
                .tabItem {
                    Image(systemName: "square.and.arrow.up")
                    Text("Page 2")
                }
            
            Page3View()
                .tabItem {
                    Image(systemName: "music.note")
                    Text("Page 3")
                }
            
            Text("Settings and stuff")
                .tabItem {
                    Image(systemName: "person")
                    Text("Page 4")
                }
        }
    }
}

struct MainView: View {
    @Binding var isListening: Bool

    var body: some View {
        ZStack {
            BackgroundView(isListening: $isListening)
            VStack {
                ProductTextView(productName: "AudioInsight")

                Spacer()

                MainStatusView(isListening: $isListening, imageName: isListening ? "ear.badge.waveform" : "ear.trianglebadge.exclamationmark")
                    .padding(.bottom, 40)

                Spacer()
            }

            if isListening {
                ForEach(0..<10) { index in
                    MusicNoteView(index: index)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct DefaultView: View {
    var dayOfWeek: String
    var imageName: String

    var body: some View {
        VStack {
            Text(dayOfWeek)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.white)
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
        }
    }
}

struct BackgroundView: View {
    @Binding var isListening: Bool

    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.black , .gray]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

struct ProductTextView: View {
    var productName: String

    var body: some View {
        Text(productName)
            .font(.system(size: 32, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .padding()
    }
}

struct MainStatusView: View {
    @Binding var isListening: Bool
    @State private var showDocumentPicker = false

    var imageName: String

    var body: some View {
        VStack(spacing: 8) {
            if !isListening {
                Button(action: {
                    showDocumentPicker = true
                }) {
                    Text("Upload File")
                        .font(.system(size: 20, weight: .bold))
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 1)
                        )
                }
                .padding(.bottom, 20) // Add some padding below the button
                .sheet(isPresented: $showDocumentPicker) {
                    DocumentPickerView(isPresented: $showDocumentPicker)
                }
            }

            Text(isListening ? "Listening..." : "Waiting...")
                .font(.system(size: 20, weight: .light))
                .foregroundColor(.white)

            Button(action: {
                withAnimation {
                    isListening.toggle()
                }
            }) {
                Image(systemName: imageName)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 180)
                    .font(.system(size: 70, weight: .light))
                    .foregroundColor(.white)
                    .offset(x: imageName == "ear.trianglebadge.exclamationmark" ? 10 : 0)
                    .transition(.opacity)
            }
        }
    }
}

struct ListenButton: View {
    var title: String
    var textColor: Color
    var backgroundColor: Color

    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(textColor)
            .padding()
            .background(backgroundColor)
            .cornerRadius(10)
    }
}

struct DocumentPickerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPickerView

        init(parent: DocumentPickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.isPresented = false
            guard let url = urls.first else { return }
            do {
                let data = try Data(contentsOf: url)
                // Handle the selected file data
                print("File selected: \(data)")
            } catch {
                print("Failed to read file data: \(error)")
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.isPresented = false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}

struct MusicNoteView: View {
    let index: Int
    @State private var animate = false

    var body: some View {
        Image(systemName: "music.note")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .foregroundColor(.white) // Change this line to set the color to pink
            .offset(x: self.animate ? CGFloat.random(in: -200...200) : 0, y: self.animate ? CGFloat.random(in: -200...200) : 0)
            .opacity(self.animate ? 0 : 1)
            .onAppear {
                self.startAnimation(index: index)
            }
    }

    private func startAnimation(index: Int) {
        withAnimation(Animation.easeOut(duration: 1).delay(Double(index) * 0.1)) {
            self.animate = true
        }
        // Reset animation state to keep it continuous
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.animate = false
            self.startAnimation(index: index)
        }
    }
}

struct Page3View: View {
    @State private var selectedCategory: Category = .genre
    @State private var genres = ["Rock", "Jazz", "Pop", "Metal", "HipHop", "Classical"]
    @State private var auras = ["Aura1", "Aura2", "Aura3", "Aura4", "Aura5", "Aura6"]
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    selectedCategory = .genre
                }) {
                    Text("Genre")
                        .padding()
                        .background(selectedCategory == .genre ? Color.pink : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    selectedCategory = .aura
                }) {
                    Text("Aura")
                        .padding()
                        .background(selectedCategory == .aura ? Color.pink : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    if selectedCategory == .genre {
                        ForEach(genres, id: \.self) { genre in
                            CategoryItemView(name: genre)
                        }
                    } else {
                        ForEach(auras, id: \.self) { aura in
                            CategoryItemView(name: aura)
                        }
                    }
                }
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [.black, .gray]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea())
    }
}

struct CategoryItemView: View {
    var name: String
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.blue)
                .frame(height: 100)
                .cornerRadius(10)
            
            Text(name)
                .foregroundColor(.white)
        }
        .padding()
    }
}

enum Category {
    case genre, aura
}
