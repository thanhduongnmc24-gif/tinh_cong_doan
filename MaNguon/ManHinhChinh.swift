import UIKit

final class ManHinhChinh: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var thang = TienIchNgay.dauThang(Date())
    private let tieuDeThang = UILabel()
    private let tieuDeThongKe = UILabel()
    private let chonTab = UISegmentedControl(items: ["Thống kê", "Công đoạn dư"])
    private let noiDungTongHop = UILabel()

    private lazy var luoi: UICollectionView = {
        let boCuc = UICollectionViewFlowLayout()
        boCuc.minimumLineSpacing = 7
        boCuc.minimumInteritemSpacing = 7
        let luoi = UICollectionView(frame: .zero, collectionViewLayout: boCuc)
        luoi.dataSource = self
        luoi.delegate = self
        luoi.register(ONgay.self, forCellWithReuseIdentifier: ONgay.ma)
        luoi.backgroundColor = .systemGroupedBackground
        return luoi
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tính công & sản lượng"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill"),
            style: .plain,
            target: self,
            action: #selector(moCaiDat)
        )
        taoGiaoDien()
        nap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nap()
    }

    private func taoGiaoDien() {
        let truoc = UIButton(type: .system)
        let sau = UIButton(type: .system)
        truoc.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        sau.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        truoc.addTarget(self, action: #selector(thangTruoc), for: .touchUpInside)
        sau.addTarget(self, action: #selector(thangSau), for: .touchUpInside)

        tieuDeThang.font = .systemFont(ofSize: 21, weight: .bold)
        tieuDeThang.textAlignment = .center
        let hangThang = UIStackView(arrangedSubviews: [truoc, tieuDeThang, sau])
        hangThang.distribution = .equalCentering

        let hangThu = UIStackView()
        ["CN", "T2", "T3", "T4", "T5", "T6", "T7"].forEach { chu in
            let nhan = UILabel()
            nhan.text = chu
            nhan.font = .systemFont(ofSize: 12, weight: .bold)
            nhan.textAlignment = .center
            nhan.textColor = chu == "CN" ? .systemRed : .secondaryLabel
            hangThu.addArrangedSubview(nhan)
        }
        hangThu.distribution = .fillEqually

        tieuDeThongKe.text = "THỐNG KÊ THÁNG"
        tieuDeThongKe.font = .systemFont(ofSize: 17, weight: .bold)
        tieuDeThongKe.textAlignment = .center

        chonTab.selectedSegmentIndex = 0
        chonTab.addTarget(self, action: #selector(doiTab), for: .valueChanged)

        noiDungTongHop.numberOfLines = 0
        noiDungTongHop.font = .monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        noiDungTongHop.backgroundColor = .secondarySystemGroupedBackground
        noiDungTongHop.layer.cornerRadius = 14
        noiDungTongHop.clipsToBounds = true

        [hangThang, hangThu, luoi, tieuDeThongKe, chonTab, noiDungTongHop].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            hangThang.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            hangThang.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hangThang.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            hangThu.topAnchor.constraint(equalTo: hangThang.bottomAnchor, constant: 8),
            hangThu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            hangThu.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            luoi.topAnchor.constraint(equalTo: hangThu.bottomAnchor, constant: 5),
            luoi.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            luoi.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            luoi.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.43),
            tieuDeThongKe.topAnchor.constraint(equalTo: luoi.bottomAnchor, constant: 8),
            tieuDeThongKe.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tieuDeThongKe.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            chonTab.topAnchor.constraint(equalTo: tieuDeThongKe.bottomAnchor, constant: 6),
            chonTab.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            chonTab.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            noiDungTongHop.topAnchor.constraint(equalTo: chonTab.bottomAnchor, constant: 7),
            noiDungTongHop.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            noiDungTongHop.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            noiDungTongHop.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }

    private func nap() {
        let dinhDang = DateFormatter()
        dinhDang.locale = Locale(identifier: "vi_VN")
        dinhDang.dateFormat = "'Tháng' M yyyy"
        tieuDeThang.text = dinhDang.string(from: thang).capitalized
        luoi.reloadData()
        capNhatTab()
    }

    @objc private func doiTab() { capNhatTab() }
    @objc private func thangTruoc() { thang = TienIchNgay.lich.date(byAdding: .month, value: -1, to: thang)!; nap() }
    @objc private func thangSau() { thang = TienIchNgay.lich.date(byAdding: .month, value: 1, to: thang)!; nap() }
    @objc private func moCaiDat() { navigationController?.pushViewController(ManHinhCaiDat(), animated: true) }

    private func capNhatTab() {
        noiDungTongHop.text = chonTab.selectedSegmentIndex == 0 ? noiDungThongKe() : noiDungCongDoanDu()
    }

    private func noiDungThongKe() -> String {
        let lich = TienIchNgay.lich
        let homNay = lich.startOfDay(for: Date())
        let laThangHienTai = lich.isDate(thang, equalTo: homNay, toGranularity: .month)
        let ngayCuoiThang = lich.date(byAdding: .day, value: TienIchNgay.soNgay(thang) - 1, to: thang)!
        let ngayChot = laThangHienTai ? homNay : ngayCuoiThang
        var ngayCongThang = 0, ngayCongDenHienTai = 0, ngayCongConLai = 0, phutThucTe = 0, ngayDaNhap = 0
        var tongPhanTram = 0.0

        for viTri in 0..<TienIchNgay.soNgay(thang) {
            let ngay = lich.date(byAdding: .day, value: viTri, to: thang)!
            let dauNgay = lich.startOfDay(for: ngay)
            if !TienIchNgay.laChuNhat(ngay) {
                ngayCongThang += 1
                if dauNgay <= ngayChot { ngayCongDenHienTai += 1 } else { ngayCongConLai += 1 }
            }
            guard dauNgay <= ngayChot else { continue }
            let duLieu = KhoDuLieu.dungChung.cacNgay[TienIchNgay.khoa.string(from: ngay)] ?? TienIchNgay.macDinh(ngay)
            phutThucTe += duLieu.phutLam
            if duLieu.daTinh {
                tongPhanTram += duLieu.phanTram
                ngayDaNhap += 1
            }
        }

        let gioThang = Double(ngayCongThang * 8)
        let gioDenHienTai = Double(ngayCongDenHienTai * 8)
        let gioThucTe = Double(phutThucTe) / 60
        let gioThieu = max(0, gioDenHienTai - gioThucTe)
        let mucTieu = KhoDuLieu.dungChung.caiDat.mucTieuThang
        let hienTai = ngayDaNhap > 0 ? tongPhanTram / Double(ngayDaNhap) : 0
        let conThieu = max(0, mucTieu - hienTai)
        let canMoiNgay = ngayCongConLai > 0 ? max(0, mucTieu * Double(ngayCongThang) - tongPhanTram) / Double(ngayCongConLai) : 0

        return String(format: "  Định mức công: %.0f giờ\n  Hiện tại: %.2f/%.0f giờ, thiếu %.2f giờ\n\n  Sản lượng tháng: %.2f%%\n  Hiện tại: %.2f%%\n  Còn thiếu: %.2f%%, cần %.2f%%/ngày", gioThang, gioThucTe, gioDenHienTai, gioThieu, mucTieu, hienTai, conThieu, canMoiNgay)
    }

    private func noiDungCongDoanDu() -> String {
        let danhSach = KhoCongDoanDu.dungChung.danhSach
        guard !danhSach.isEmpty else { return "  Chưa có công đoạn dư." }
        let cacDong = danhSach.map { "  \($0.heSo.chuoiGon)%  |  \($0.soLuong.chuoiGon) tờ" }
        return (["  PHẦN TRĂM  |  SỐ TỜ", ""] + cacDong).joined(separator: "\n")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        TienIchNgay.soNgay(thang) + TienIchNgay.lich.component(.weekday, from: thang) - 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let o = collectionView.dequeueReusableCell(withReuseIdentifier: ONgay.ma, for: indexPath) as! ONgay
        let lech = TienIchNgay.lich.component(.weekday, from: thang) - 1
        if indexPath.item < lech { o.isHidden = true; return o }
        o.isHidden = false
        let ngay = TienIchNgay.lich.date(byAdding: .day, value: indexPath.item - lech, to: thang)!
        o.gan(ngay: ngay, duLieu: KhoDuLieu.dungChung.cacNgay[TienIchNgay.khoa.string(from: ngay)] ?? TienIchNgay.macDinh(ngay))
        return o
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let lech = TienIchNgay.lich.component(.weekday, from: thang) - 1
        guard indexPath.item >= lech else { return }
        let ngay = TienIchNgay.lich.date(byAdding: .day, value: indexPath.item - lech, to: thang)!
        let duLieu = KhoDuLieu.dungChung.cacNgay[TienIchNgay.khoa.string(from: ngay)] ?? TienIchNgay.macDinh(ngay)
        present(UINavigationController(rootViewController: ManHinhNgay(ngay: ngay, duLieu: duLieu) { [weak self] in self?.nap() }), animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let rong = floor((collectionView.bounds.width - 42) / 7)
        return CGSize(width: rong, height: max(48, floor(collectionView.bounds.height / 6) - 6))
    }
}
