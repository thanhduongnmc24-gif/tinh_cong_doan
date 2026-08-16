import UIKit
final class ManHinhChinh: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var thang = TienIchNgay.dauThang(Date())
    private let tieuDe = UILabel(), tongKet = UILabel()
    private lazy var luoi:UICollectionView = {let l = UICollectionViewFlowLayout();l.minimumLineSpacing = 7;l.minimumInteritemSpacing = 7;let v = UICollectionView(frame:.zero,collectionViewLayout:l);v.dataSource = self;v.delegate = self;v.register(ONgay.self,forCellWithReuseIdentifier:ONgay.ma);v.backgroundColor = .systemGroupedBackground;return v}()
    override func viewDidLoad(){super.viewDidLoad();title = "Tính công & sản lượng";view.backgroundColor = .systemGroupedBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image:UIImage(systemName:"gearshape.fill"),style:.plain,target:self,action:#selector(moCaiDat))
        let truoc = UIButton(type:.system),sau = UIButton(type:.system);truoc.setImage(UIImage(systemName:"chevron.left"),for:.normal);sau.setImage(UIImage(systemName:"chevron.right"),for:.normal);truoc.addTarget(self,action:#selector(thangTruoc),for:.touchUpInside);sau.addTarget(self,action:#selector(thangSau),for:.touchUpInside)
        tieuDe.font = .systemFont(ofSize:21,weight:.bold);tieuDe.textAlignment = .center
        let dau = UIStackView(arrangedSubviews:[truoc,tieuDe,sau]);dau.distribution = .equalCentering
        let thu = UIStackView();["CN","T2","T3","T4","T5","T6","T7"].forEach{let x = UILabel();x.text = $0;x.font = .systemFont(ofSize:12,weight:.bold);x.textAlignment = .center;x.textColor = $0=="CN" ? .systemRed:.secondaryLabel;thu.addArrangedSubview(x)};thu.distribution = .fillEqually
        tongKet.numberOfLines = 0;tongKet.font = .monospacedDigitSystemFont(ofSize:14,weight:.semibold);tongKet.backgroundColor = .secondarySystemGroupedBackground;tongKet.layer.cornerRadius = 14;tongKet.clipsToBounds = true
        [dau,thu,luoi,tongKet].forEach{$0.translatesAutoresizingMaskIntoConstraints = false;view.addSubview($0)}
        NSLayoutConstraint.activate([dau.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor,constant:8),dau.leadingAnchor.constraint(equalTo:view.leadingAnchor,constant:16),dau.trailingAnchor.constraint(equalTo:view.trailingAnchor,constant:-16),thu.topAnchor.constraint(equalTo:dau.bottomAnchor,constant:10),thu.leadingAnchor.constraint(equalTo:view.leadingAnchor,constant:10),thu.trailingAnchor.constraint(equalTo:view.trailingAnchor,constant:-10),luoi.topAnchor.constraint(equalTo:thu.bottomAnchor,constant:5),luoi.leadingAnchor.constraint(equalTo:view.leadingAnchor,constant:8),luoi.trailingAnchor.constraint(equalTo:view.trailingAnchor,constant:-8),luoi.bottomAnchor.constraint(equalTo:tongKet.topAnchor,constant:-8),tongKet.leadingAnchor.constraint(equalTo:view.leadingAnchor,constant:12),tongKet.trailingAnchor.constraint(equalTo:view.trailingAnchor,constant:-12),tongKet.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor,constant:-8),tongKet.heightAnchor.constraint(equalToConstant:150)])
        nap()
    }
    override func viewWillAppear(_ animated:Bool){super.viewWillAppear(animated);nap()}
    private func nap(){let f = DateFormatter();f.locale = Locale(identifier:"vi_VN");f.dateFormat = "'Tháng' M yyyy";tieuDe.text = f.string(from:thang).capitalized;luoi.reloadData();thongKe()}
    @objc private func thangTruoc(){thang = TienIchNgay.lich.date(byAdding:.month,value:-1,to:thang)!;nap()}
    @objc private func thangSau(){thang = TienIchNgay.lich.date(byAdding:.month,value:1,to:thang)!;nap()}
    @objc private func moCaiDat(){navigationController?.pushViewController(ManHinhCaiDat(),animated:true)}
    func collectionView(_ c:UICollectionView,numberOfItemsInSection s:Int)->Int{TienIchNgay.soNgay(thang)+TienIchNgay.lich.component(.weekday,from:thang)-1}
    func collectionView(_ c:UICollectionView,cellForItemAt i:IndexPath)->UICollectionViewCell{let o = c.dequeueReusableCell(withReuseIdentifier:ONgay.ma,for:i) as! ONgay;let lech = TienIchNgay.lich.component(.weekday,from:thang)-1;if i.item<lech{o.isHidden = true;return o};o.isHidden = false;let d = TienIchNgay.lich.date(byAdding:.day,value:i.item-lech,to:thang)!;o.gan(ngay:d,duLieu:KhoDuLieu.dungChung.cacNgay[TienIchNgay.khoa.string(from:d)] ?? TienIchNgay.macDinh(d));return o}
    func collectionView(_ c:UICollectionView,didSelectItemAt i:IndexPath){let lech = TienIchNgay.lich.component(.weekday,from:thang)-1;guard i.item>=lech else{return};let d = TienIchNgay.lich.date(byAdding:.day,value:i.item-lech,to:thang)!;let du = KhoDuLieu.dungChung.cacNgay[TienIchNgay.khoa.string(from:d)] ?? TienIchNgay.macDinh(d);present(UINavigationController(rootViewController:ManHinhNgay(ngay:d,duLieu:du){[weak self] in self?.nap()}),animated:true)}
    func collectionView(_ c:UICollectionView,layout:UICollectionViewLayout,sizeForItemAt i:IndexPath)->CGSize{let w = floor((c.bounds.width-42)/7);return CGSize(width:w,height:max(55,floor(c.bounds.height/6)-6))}
    private func thongKe() {
        let lich = TienIchNgay.lich
        let homNay = lich.startOfDay(for: Date())
        let dauThangDangXem = TienIchNgay.dauThang(thang)
        let laThangHienTai = lich.isDate(dauThangDangXem, equalTo: homNay, toGranularity: .month)
        let ngayChot = laThangHienTai ? homNay : (lich.date(byAdding: .day, value: TienIchNgay.soNgay(thang) - 1, to: thang) ?? homNay)

        var soNgayCongThang = 0
        var soNgayCongDenHienTai = 0
        var soNgayCongConLai = 0
        var phutThucTe = 0
        var tongPhanTramNgay = 0.0

        for viTri in 0..<TienIchNgay.soNgay(thang) {
            guard let ngay = lich.date(byAdding: .day, value: viTri, to: thang) else { continue }
            let dauNgay = lich.startOfDay(for: ngay)
            let laNgayCong = !TienIchNgay.laChuNhat(ngay)

            if laNgayCong {
                soNgayCongThang += 1
                if dauNgay <= ngayChot {
                    soNgayCongDenHienTai += 1
                } else {
                    soNgayCongConLai += 1
                }
            }

            guard dauNgay <= ngayChot else { continue }
            let duLieu = KhoDuLieu.dungChung.cacNgay[TienIchNgay.khoa.string(from: ngay)] ?? TienIchNgay.macDinh(ngay)
            phutThucTe += duLieu.phutLam
            tongPhanTramNgay += duLieu.phanTram
        }

        let gioDinhMucThang = Double(soNgayCongThang * 8)
        let gioDinhMucHienTai = Double(soNgayCongDenHienTai * 8)
        let gioHienTai = Double(phutThucTe) / 60.0
        let gioThieu = max(0, gioDinhMucHienTai - gioHienTai)

        let mucTieu = KhoDuLieu.dungChung.caiDat.mucTieuThang
        let sanLuongHienTai = soNgayCongThang > 0 ? tongPhanTramNgay / Double(soNgayCongThang) : 0
        let sanLuongConThieu = max(0, mucTieu - sanLuongHienTai)
        let tongDiemCanDat = mucTieu * Double(soNgayCongThang)
        let canMoiNgay = soNgayCongConLai > 0
            ? max(0, tongDiemCanDat - tongPhanTramNgay) / Double(soNgayCongConLai)
            : 0

        tongKet.text = String(
            format: "  THỐNG KÊ THÁNG\n  Định mức công: %.0f giờ\n  Hiện tại: %.2f/%.0f giờ, thiếu %.2f giờ\n  Sản lượng tháng: %.2f%%\n  Hiện tại: %.2f%%, còn thiếu %.2f%%, cần %.2f%%/ngày",
            gioDinhMucThang,
            gioHienTai,
            gioDinhMucHienTai,
            gioThieu,
            mucTieu,
            sanLuongHienTai,
            sanLuongConThieu,
            canMoiNgay
        )
    }
}
