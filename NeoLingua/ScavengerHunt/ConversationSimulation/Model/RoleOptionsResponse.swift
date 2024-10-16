import Foundation

struct RoleOption: Codable, Identifiable {
    let id: UUID
    let role: String
    let tasks: [String]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.role = try container.decode(String.self, forKey: .role)
        self.tasks = try container.decode([String].self, forKey: .tasks)
        self.id = UUID()
    }
}

struct RoleOptionsResponse: Codable, Identifiable {
    let roleOptions: [RoleOption]
    let id: UUID
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.roleOptions = try container.decode([RoleOption].self, forKey: .roleOptions)
            id = UUID()
        }
}
