import Foundation

struct CartItem: Hashable {
    var id: UUID
    var name: String
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
    
    static func mockArray() -> [Self] {
        return [
            .init(name: "간장"),
            .init(name: "된장"),
            .init(name: "고추장"),
            .init(name: "오이"),
            .init(name: "배추"),
        ]
    }
}
