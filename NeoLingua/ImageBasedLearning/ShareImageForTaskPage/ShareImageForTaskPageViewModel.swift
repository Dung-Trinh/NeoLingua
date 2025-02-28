import SwiftUI

protocol ShareImageForTaskPageViewModel: ObservableObject {
    
}

class ShareImageForTaskPageViewModelImpl: ShareImageForTaskPageViewModel {
    @Published var vocabulary = ""
    @Published var approvedVocabulary = Set<String>()
    @Published var verifiedVocabular: [VerifiedVocabular] = []
    @Published var isLoading: Bool = false
    @Published var isSheetPresented: Bool = false
    
    private var imageProcessingManager = ImageProcessingManager()
    let sharedContentForTask: SharedContentForTask

    init(sharedContentForTask: SharedContentForTask) {
        self.sharedContentForTask = sharedContentForTask
    }
    
    func validateVocabulary() async {
        isLoading = true
        defer { isLoading = false }
        
        print(vocabulary)
        let vocabularyArray = vocabulary.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        print(vocabularyArray.description)
        
        do {
            verifiedVocabular = try await imageProcessingManager.validateVocabularyInImage(imageUrl: sharedContentForTask.uploadedLink, vocabulary: vocabularyArray)
            print("verifiedVocabular")
            print(verifiedVocabular)
            vocabulary = ""
        } catch {
            print("validateVocabulary error: ", error.localizedDescription)
        }
    }
    
    func addVocabulary(vocabulary: String){
        approvedVocabulary.insert(vocabulary)
    }
    
    func saveContent() {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try imageProcessingManager.saveSnapVocabularyTask(sharedContentForTask: sharedContentForTask, vocabulary: Array(approvedVocabulary))
            isSheetPresented = true
        } catch {
            print("saveContent error")
        }
    }
}
