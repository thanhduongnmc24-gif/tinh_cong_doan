import Foundation

struct CongDoan: Codable, Hashable {
    var ma = UUID()
    var soLuong: Double = 0
    var heSo: Double = 0
}

struct DuLieuNgay: Codable {
    var khoaNgay: String
    var gioBatDau: Date
    var gioKetThuc: Date
    var nghiPhut: Int
    var nghiLam: Bool
    var phutChuan: Double
    var congDoan: [CongDoan]
    var phanTram: Double
    var daTinh: Bool

    var phutLam: Int {
        if nghiLam { return 0 }
        return max(0, Int(gioKetThuc.timeIntervalSince(gioBatDau) / 60) - nghiPhut)
    }
    var soCong: Double { Double(phutLam) / 480.0 }
}

struct CaiDat: Codable {
    var gioBatDau = 7
    var phutBatDau = 30
    var gioKetThuc = 16
    var phutKetThuc = 30
    var nghiPhut = 60
    var phutChuan = 720.0
    var mucTieuThang = 100.0
}

final class KhoDuLieu {
    static let dungChung = KhoDuLieu()
    private let khoaNgay = "du-lieu-ngay-v1"
    private let khoaCaiDat = "cai-dat-v1"
    private(set) var cacNgay: [String: DuLieuNgay] = [:]
    var caiDat = CaiDat()
    private init() { doc() }
    func doc() {
        let d = UserDefaults.standard
        if let x = d.data(forKey: khoaNgay), let v = try? JSONDecoder().decode([String: DuLieuNgay].self, from: x) { cacNgay = v }
        if let x = d.data(forKey: khoaCaiDat), let v = try? JSONDecoder().decode(CaiDat.self, from: x) { caiDat = v }
    }
    func luu(_ ngay: DuLieuNgay) {
        cacNgay[ngay.khoaNgay] = ngay
        if let x = try? JSONEncoder().encode(cacNgay) { UserDefaults.standard.set(x, forKey: khoaNgay) }
    }
    func luuCaiDat(_ moi: CaiDat) {
        caiDat = moi
        if let x = try? JSONEncoder().encode(moi) { UserDefaults.standard.set(x, forKey: khoaCaiDat) }
    }
}

enum TienIchNgay {
    static var lich: Calendar { var c = Calendar(identifier: .gregorian); c.locale = Locale(identifier: "vi_VN"); c.timeZone = .current; return c }
    static let khoa: DateFormatter = { let f = DateFormatter(); f.calendar = lich; f.locale = Locale(identifier:"vi_VN"); f.dateFormat = "yyyy-MM-dd"; return f }()
    static func dauThang(_ d: Date) -> Date { lich.date(from: lich.dateComponents([.year,.month], from:d))! }
    static func soNgay(_ d: Date) -> Int { lich.range(of:.day, in:.month, for:d)!.count }
    static func laChuNhat(_ d: Date) -> Bool { lich.component(.weekday, from:d) == 1 }
    static func taoGio(ngay: Date, gio: Int, phut: Int) -> Date { lich.date(bySettingHour:gio, minute:phut, second:0, of:ngay)! }
    static func macDinh(_ ngay: Date) -> DuLieuNgay {
        let c = KhoDuLieu.dungChung.caiDat
        return DuLieuNgay(khoaNgay:khoa.string(from:ngay), gioBatDau:taoGio(ngay:ngay,gio:c.gioBatDau,phut:c.phutBatDau), gioKetThuc:taoGio(ngay:ngay,gio:c.gioKetThuc,phut:c.phutKetThuc), nghiPhut:c.nghiPhut, nghiLam:laChuNhat(ngay), phutChuan:c.phutChuan, congDoan:[CongDoan()], phanTram:0, daTinh:false)
    }
}
