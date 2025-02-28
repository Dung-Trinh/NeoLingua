import SwiftUI
import Lottie

struct ImageValidationResultView: View {
    let validationResult: ImageValidationResult
    
    var body: some View {
        VStack {
            LottieView(animation: .named(validationResult.isMatching ? "firework": "crossmark"))
                .looping()
                .frame(width: .infinity, height: 200)
                .padding(-30)
            
            Text(validationResult.isMatching ? "The image matches the searched object!" : "The image does not match the searched object.")
                .font(.title3)
                .bold()
                .foregroundColor(validationResult.isMatching ? .green : .red)
                .multilineTextAlignment(.center)
                .padding(.bottom, Styleguide.Margin.small)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack() {
                    Text("🎯 Confidence Score:")
                        .font(.headline)
                        .bold()
                    Text("\(validationResult.confidenceScore * 100, specifier: "%.1f")%")
                        .font(.subheadline)
                }
                if validationResult.reason != "" {
                    VStack(alignment: .leading) {
                        Text("🔎 Reason:")
                            .font(.headline)
                            .bold()
                            .multilineTextAlignment(.leading)
                        Text(validationResult.reason)
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                    }
                }
            }.padding()
        }
    }
}
