import SwiftUI
import Lottie

struct TaskCompleteSheetView: View {
    let taskPerformance: TaskPerformancetParameter
    let action: () -> Void?
    
    var body: some View {
        VStack {
            LottieView(animation: .named("firework"))
                .looping()
                .frame(width: 200, height: 200)
                .padding(-30)
            Text("Übung absolviert!").font(.title).bold().foregroundColor(.green)
            HStack {
                VStack {
                    Text("💎 Punkte")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("\(taskPerformance.finalPoints ?? 0, specifier: "%.2f") ")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                VStack {
                    Text("🎯 Genauigkeit")
                        .font(.headline)
                        .foregroundColor(.purple)
                    Text("\(Int(taskPerformance.result * 100)) %").font(.subheadline)
                        .foregroundColor(.purple)
                        .bold()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }

            Spacer()
            PrimaryButton(
                title: "Zurück zur Übersicht",
                color: .blue,
                action: {
                    action()
                }
            )
        }
        .presentationDetents([.fraction(0.5)])
        .presentationCornerRadius(40)
        .padding()
    }
}
