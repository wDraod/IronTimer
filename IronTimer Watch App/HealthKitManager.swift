import Foundation
import HealthKit

final class HealthKitManager: HeartRateProvider {

    static let shared = HealthKitManager()
    private init() {}

    private let store = HKHealthStore()
    private let hrType = HKQuantityType(.heartRate)
    private let hrUnit = HKUnit.count().unitDivided(by: .minute())

    private var _latestHR: Int = 0
    private let hrLock = NSLock()

    var latestHR: Int {
        hrLock.lock()
        defer { hrLock.unlock() }
        return _latestHR
    }

    private var query: HKAnchoredObjectQuery?

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        do {
            try await store.requestAuthorization(toShare: [], read: [hrType])
            return true
        } catch {
            print("[HealthKit] 授权失败: \(error)")
            return false
        }
    }

    // MARK: - Real-time Query

    func startHeartRateQuery() {
        stopHeartRateQuery()

        // 初始只取最近 1 条，避免处理大量历史数据
        let initial = HKAnchoredObjectQuery(
            type: hrType,
            predicate: nil,
            anchor: nil,
            limit: 1
        ) { [weak self] _, samples, _, anchor, _ in
            self?.process(samples: samples)

            // 用返回的 anchor 启动持续更新查询
            guard let self, let anchor else { return }
            let updateQuery = HKAnchoredObjectQuery(
                type: self.hrType,
                predicate: nil,
                anchor: anchor,
                limit: HKObjectQueryNoLimit
            ) { [weak self] _, samples, _, _, _ in
                self?.process(samples: samples)
            }
            updateQuery.updateHandler = { [weak self] _, samples, _, _, _ in
                self?.process(samples: samples)
            }
            self.store.execute(updateQuery)
            self.query = updateQuery
        }

        store.execute(initial)
    }

    func stopHeartRateQuery() {
        if let q = query {
            store.stop(q)
            query = nil
        }
    }

    // MARK: - Private

    private func process(samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else { return }
        let latest = samples.sorted { $0.startDate < $1.startDate }.last!
        let bpm = Int(latest.quantity.doubleValue(for: hrUnit))

        hrLock.lock()
        _latestHR = bpm
        hrLock.unlock()

        print("[HealthKit] 心率更新: \(bpm) bpm")
    }
}
