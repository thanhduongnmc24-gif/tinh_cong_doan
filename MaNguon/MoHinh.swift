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

struct CongDoanDu: Codable, Hashable {
    var heSo: Double
    var soLuong: Double
}

final class KhoCongDoanDu {
    static let dungChung = KhoCongDoanDu()
    private let khoa = "cong-doan-du-v3-doc-lap"
    private(set) var danhSach: [CongDoanDu] = []
    private init() { if let d = UserDefaults.standard.data(forKey: khoa), let v = try? JSONDecoder().decode([CongDoanDu].self, from: d) { danhSach = v.sorted { $0.heSo < $1.heSo } } }
    func thuCongDon(_ ds: [CongDoan]) -> String? {
        var bang = Dictionary(uniqueKeysWithValues: danhSach.map { ($0.heSo, $0.soLuong) })
        for d in ds where d.heSo > 0 && d.soLuong != 0 {
            let cu = bang[d.heSo, default: 0], moi = cu + d.soLuong
            if moi < -0.000001 { return "Loại \(d.heSo.chuoiGon)% chỉ còn \(cu.chuoiGon) tờ, không thể trừ \((-d.soLuong).chuoiGon) tờ." }
            bang[d.heSo] = max(0, moi)
        }
        danhSach = bang.filter { $0.value > 0.000001 }.map { CongDoanDu(heSo: $0.key, soLuong: $0.value) }.sorted { $0.heSo < $1.heSo }
        if let d = try? JSONEncoder().encode(danhSach) { UserDefaults.standard.set(d, forKey: khoa) }
        return nil
    }
}

final class KhoDuLieu {
    static let dungChung = KhoDuLieu()
    private let khoaNgay = "du-lieu-ngay-v1"
    private let khoaCaiDat = "cai-dat-v1"
    private(set) var cacNgay: [String: DuLieuNgay] = [:]
    var caiDat = CaiDat()

    private init() { doc() }

    func doc() {
        let macDinh = UserDefaults.standard
        if let duLieu = macDinh.data(forKey: khoaNgay),
           let giaTri = try? JSONDecoder().decode([String: DuLieuNgay].self, from: duLieu) {
            cacNgay = giaTri
        }
        if let duLieu = macDinh.data(forKey: khoaCaiDat),
           let giaTri = try? JSONDecoder().decode(CaiDat.self, from: duLieu) {
            caiDat = giaTri
        }
    }

    func luu(_ ngay: DuLieuNgay) {
        cacNgay[ngay.khoaNgay] = ngay
        if let duLieu = try? JSONEncoder().encode(cacNgay) {
            UserDefaults.standard.set(duLieu, forKey: khoaNgay)
        }
    }

    func luuCaiDat(_ moi: CaiDat) {
        caiDat = moi
        if let duLieu = try? JSONEncoder().encode(moi) {
            UserDefaults.standard.set(duLieu, forKey: khoaCaiDat)
        }
    }
}

enum TienIchNgay {
    static var lich: Calendar {
        var lich = Calendar(identifier: .gregorian)
        lich.locale = Locale(identifier: "vi_VN")
        lich.timeZone = .current
        return lich
    }

    static let khoa: DateFormatter = {
        let dinhDang = DateFormatter()
        dinhDang.calendar = lich
        dinhDang.locale = Locale(identifier: "vi_VN")
        dinhDang.dateFormat = "yyyy-MM-dd"
        return dinhDang
    }()

    static func dauThang(_ ngay: Date) -> Date {
        lich.date(from: lich.dateComponents([.year, .month], from: ngay))!
    }

    static func soNgay(_ ngay: Date) -> Int {
        lich.range(of: .day, in: .month, for: ngay)!.count
    }

    static func laChuNhat(_ ngay: Date) -> Bool {
        lich.component(.weekday, from: ngay) == 1
    }

    static func chuNgayAm(_ ngay: Date) -> String {
        var lichAm = Calendar(identifier: .chinese)
        lichAm.locale = Locale(identifier: "vi_VN")
        lichAm.timeZone = .current
        let thanhPhan = lichAm.dateComponents([.day, .month], from: ngay)
        guard let ngayAm = thanhPhan.day, let thangAm = thanhPhan.month else { return "" }
        return ngayAm == 1 ? "1/\(thangAm)" : "\(ngayAm)"
    }

    static func taoGio(ngay: Date, gio: Int, phut: Int) -> Date {
        lich.date(bySettingHour: gio, minute: phut, second: 0, of: ngay)!
    }

    static func macDinh(_ ngay: Date) -> DuLieuNgay {
        let caiDat = KhoDuLieu.dungChung.caiDat
        return DuLieuNgay(
            khoaNgay: khoa.string(from: ngay),
            gioBatDau: taoGio(ngay: ngay, gio: caiDat.gioBatDau, phut: caiDat.phutBatDau),
            gioKetThuc: taoGio(ngay: ngay, gio: caiDat.gioKetThuc, phut: caiDat.phutKetThuc),
            nghiPhut: caiDat.nghiPhut,
            nghiLam: laChuNhat(ngay),
            phutChuan: caiDat.phutChuan,
            congDoan: [CongDoan()],
            phanTram: 0,
            daTinh: false
        )
    }
}

extension Double {
    var chuoiGon: String {
        if rounded() == self { return String(format: "%.0f", self) }
        return String(format: "%.4f", self)
            .replacingOccurrences(of: "0+$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\.$", with: "", options: .regularExpression)
    }
}
