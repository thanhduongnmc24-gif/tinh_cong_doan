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

final class ThuMucDuLieu {
    static let dungChung = ThuMucDuLieu()

    let thuMuc: URL
    let tepNgay: URL
    let tepCongDoanDu: URL
    let tepCaiDat: URL

    private let maHoa: JSONEncoder = {
        let boMaHoa = JSONEncoder()
        boMaHoa.outputFormatting = [.prettyPrinted, .sortedKeys]
        return boMaHoa
    }()

    private let giaiMa = JSONDecoder()

    private init() {
        let documents = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        thuMuc = documents.appendingPathComponent(
            "DuLieuTinhCong",
            isDirectory: true
        )
        tepNgay = thuMuc.appendingPathComponent("du-lieu-ngay.json")
        tepCongDoanDu = thuMuc.appendingPathComponent("cong-doan-du.json")
        tepCaiDat = thuMuc.appendingPathComponent("cai-dat.json")

        try? FileManager.default.createDirectory(
            at: thuMuc,
            withIntermediateDirectories: true
        )
        taoHuongDanNeuCan()
    }

    func doc<T: Decodable>(_ loai: T.Type, tu tep: URL) -> T? {
        guard let duLieu = try? Data(contentsOf: tep) else { return nil }
        return try? giaiMa.decode(loai, from: duLieu)
    }

    @discardableResult
    func ghi<T: Encodable>(_ giaTri: T, vao tep: URL) -> Bool {
        do {
            let duLieu = try maHoa.encode(giaTri)
            try duLieu.write(to: tep, options: .atomic)
            return true
        } catch {
            print("Không thể ghi dữ liệu: \(error.localizedDescription)")
            return false
        }
    }

    private func taoHuongDanNeuCan() {
        let tepHuongDan = thuMuc.appendingPathComponent("HUONG-DAN.txt")
        guard !FileManager.default.fileExists(atPath: tepHuongDan.path) else { return }
        let noiDung = """
        DỮ LIỆU TÍNH CÔNG
        Sao chép nguyên thư mục DuLieuTinhCong sang ứng dụng trên máy khác để chuyển dữ liệu.
        Các tệp JSON được ứng dụng tự động đọc và cập nhật.

        TIMEKEEPING DATA
        Copy the entire DuLieuTinhCong folder to the app on another device to transfer data.
        The JSON files are read and updated automatically by the app.
        """
        try? noiDung.write(to: tepHuongDan, atomically: true, encoding: .utf8)
    }
}

final class KhoCongDoanDu {
    static let dungChung = KhoCongDoanDu()
    private let khoaCu = "cong-doan-du-v3-doc-lap"
    private(set) var danhSach: [CongDoanDu] = []

    private init() {
        let tep = ThuMucDuLieu.dungChung.tepCongDoanDu
        if let giaTri = ThuMucDuLieu.dungChung.doc([CongDoanDu].self, tu: tep) {
            danhSach = giaTri.sorted { $0.heSo < $1.heSo }
        } else if let duLieuCu = UserDefaults.standard.data(forKey: khoaCu),
                  let giaTriCu = try? JSONDecoder().decode([CongDoanDu].self, from: duLieuCu) {
            danhSach = giaTriCu.sorted { $0.heSo < $1.heSo }
            ThuMucDuLieu.dungChung.ghi(danhSach, vao: tep)
        } else {
            ThuMucDuLieu.dungChung.ghi(danhSach, vao: tep)
        }
    }

    func thuCongDon(_ ds: [CongDoan]) -> String? {
        var bang = Dictionary(
            uniqueKeysWithValues: danhSach.map { ($0.heSo, $0.soLuong) }
        )

        for dong in ds where dong.heSo > 0 && dong.soLuong != 0 {
            let cu = bang[dong.heSo, default: 0]
            let moi = cu + dong.soLuong
            if moi < -0.000001 {
                return "Loại \(dong.heSo.chuoiGon)% chỉ còn \(cu.chuoiGon) tờ, không thể trừ \((-dong.soLuong).chuoiGon) tờ."
            }
            bang[dong.heSo] = max(0, moi)
        }

        danhSach = bang
            .filter { $0.value > 0.000001 }
            .map { CongDoanDu(heSo: $0.key, soLuong: $0.value) }
            .sorted { $0.heSo < $1.heSo }

        ThuMucDuLieu.dungChung.ghi(
            danhSach,
            vao: ThuMucDuLieu.dungChung.tepCongDoanDu
        )
        return nil
    }
}

final class KhoDuLieu {
    static let dungChung = KhoDuLieu()
    private let khoaNgayCu = "du-lieu-ngay-v1"
    private let khoaCaiDatCu = "cai-dat-v1"
    private(set) var cacNgay: [String: DuLieuNgay] = [:]
    var caiDat = CaiDat()

    private init() { doc() }

    func doc() {
        let thuMuc = ThuMucDuLieu.dungChung
        let macDinh = UserDefaults.standard

        if let giaTri = thuMuc.doc([String: DuLieuNgay].self, tu: thuMuc.tepNgay) {
            cacNgay = giaTri
        } else if let duLieuCu = macDinh.data(forKey: khoaNgayCu),
                  let giaTriCu = try? JSONDecoder().decode([String: DuLieuNgay].self, from: duLieuCu) {
            cacNgay = giaTriCu
            thuMuc.ghi(cacNgay, vao: thuMuc.tepNgay)
        } else {
            thuMuc.ghi(cacNgay, vao: thuMuc.tepNgay)
        }

        if let giaTri = thuMuc.doc(CaiDat.self, tu: thuMuc.tepCaiDat) {
            caiDat = giaTri
        } else if let duLieuCu = macDinh.data(forKey: khoaCaiDatCu),
                  let giaTriCu = try? JSONDecoder().decode(CaiDat.self, from: duLieuCu) {
            caiDat = giaTriCu
            thuMuc.ghi(caiDat, vao: thuMuc.tepCaiDat)
        } else {
            thuMuc.ghi(caiDat, vao: thuMuc.tepCaiDat)
        }
    }

    func luu(_ ngay: DuLieuNgay) {
        cacNgay[ngay.khoaNgay] = ngay
        ThuMucDuLieu.dungChung.ghi(
            cacNgay,
            vao: ThuMucDuLieu.dungChung.tepNgay
        )
    }

    func luuCaiDat(_ moi: CaiDat) {
        caiDat = moi
        ThuMucDuLieu.dungChung.ghi(
            moi,
            vao: ThuMucDuLieu.dungChung.tepCaiDat
        )
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
