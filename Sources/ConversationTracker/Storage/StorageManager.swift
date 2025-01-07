import Foundation
import RealmSwift
import Logging

class StorageManager {
    static let shared = StorageManager()
    
    private let logger: Logger
    private let realm: Realm
    private let retentionPeriod: TimeInterval = 30 * 24 * 60 * 60 // 30 days
    
    private init() {
        self.logger = Logger(label: "com.audioime.storage")
        
        // Configure Realm for optimization
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                // Handle schema migrations
            },
            objectTypes: [
                ConversationSegment.self,
                Conversation.self,
                ActionItem.self,
                Topic.self,
                ProcessingMetrics.self,
                CacheEntry.self
            ]
        )
        
        self.realm = try! Realm(configuration: config)
        
        // Start maintenance tasks
        scheduleMaintenanceTasks()
    }
    
    // MARK: - Data Management
    
    func saveConversation(_ conversation: Conversation) throws {
        try realm.write {
            realm.add(conversation, update: .modified)
        }
    }
    
    func getConversation(id: String) -> Conversation? {
        realm.object(ofType: Conversation.self, forPrimaryKey: id)
    }
    
    func getRecentConversations(limit: Int = 10) -> [Conversation] {
        Array(realm.objects(Conversation.self)
            .sorted(byKeyPath: "startTime", ascending: false)
            .prefix(limit))
    }
    
    // MARK: - Cache Management
    
    func cacheValue(_ value: String, forKey key: String) throws {
        let entry = CacheEntry()
        entry.key = key
        entry.value = value
        entry.timestamp = Date()
        entry.accessCount = 1
        
        try realm.write {
            realm.add(entry, update: .modified)
        }
    }
    
    func getCachedValue(forKey key: String) -> String? {
        guard let entry = realm.object(ofType: CacheEntry.self, forPrimaryKey: key) else {
            return nil
        }
        
        try? realm.write {
            entry.accessCount += 1
        }
        
        return entry.value
    }
    
    // MARK: - Maintenance
    
    private func scheduleMaintenanceTasks() {
        Task {
            while true {
                await cleanupOldData()
                await optimizeCache()
                try? await Task.sleep(nanoseconds: UInt64(24 * 60 * 60 * 1_000_000_000)) // Daily
            }
        }
    }
    
    private func cleanupOldData() async {
        let cutoffDate = Date().addingTimeInterval(-retentionPeriod)
        
        try? realm.write {
            // Remove old conversations
            let oldConversations = realm.objects(Conversation.self)
                .filter("endTime < %@", cutoffDate)
            realm.delete(oldConversations)
            
            // Remove old metrics
            let oldMetrics = realm.objects(ProcessingMetrics.self)
                .filter("timestamp < %@", cutoffDate)
            realm.delete(oldMetrics)
        }
    }
    
    private func optimizeCache() async {
        let maxCacheEntries = 1000
        
        try? realm.write {
            let entries = realm.objects(CacheEntry.self)
                .sorted(byKeyPath: "accessCount", ascending: true)
            
            if entries.count > maxCacheEntries {
                let entriesToDelete = entries.prefix(entries.count - maxCacheEntries)
                realm.delete(entriesToDelete)
            }
        }
    }
}
