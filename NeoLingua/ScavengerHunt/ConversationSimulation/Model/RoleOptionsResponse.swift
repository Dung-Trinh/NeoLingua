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
    
    init(role: String, tasks: [String]) {
        self.role = role
        self.tasks = tasks
        self.id = UUID()
    }
}

struct RoleOptionsResponse: Codable, Identifiable {
    let id: UUID
    let contextDescription: String
    let roleOptions: [RoleOption]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.roleOptions = try container.decode([RoleOption].self, forKey: .roleOptions)
        self.contextDescription = try container.decode(String.self, forKey: .contextDescription)
        id = UUID()
    }
    
    init(contextDescription: String, roleOptions: [RoleOption]) {
        self.roleOptions = roleOptions
        self.contextDescription = contextDescription
        self.id = UUID()
    }
}
