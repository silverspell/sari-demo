# Tasarım

Ekran tasarımları Google Stitch'ten alınmıştır. QA ajanı `screens/` altındaki PNG'leri golden test çıktılarıyla karşılaştırır, bu yüzden dosya adları sabit kalmalıdır.

## Dosyalar

- `DESIGN.md`: Stitch'in tasarım sistemi (renkler, Inter tipografisi, köşe, boşluk, bileşen kuralları). Flutter karşılığı `lib/theme/sari_theme.dart`.
- `screens/`: her ekran için bir PNG. Karşılaştırmanın kaynağı bu dosyalardır.
- `stitch/<ekran>/code.html`: Stitch'in o ekran için ürettiği HTML/Tailwind. Ölçü, metin ve hiyerarşi için başvurudur; Flutter'a birebir çevrilmez.

## Ekranlar

Adlar `<sıra>-<ekran>.png` biçimindedir. Akış sırası telefon girişinden ödeme yöntemlerine kadardır.

| Dosya | Ekran |
|---|---|
| `01-phone-login.png` | Telefon numarası girişi |
| `02-otp.png` | Doğrulama kodu (statik kod `1234`) |
| `03-name.png` | "Seni nasıl çağıralım?" ad girişi |
| `04-location-permission.png` | Konum izni açıklaması |
| `05-home.png` | Ana ekran: harita, "Nereye?", kayıtlı yerler, "Taksi çağır" |
| `06-destination.png` | Nereye: varış noktası arama |
| `07-route-fare.png` | Rota ve ücret |
| `08-finding-driver.png` | Sürücü aranıyor |
| `09-driver-found.png` | Sürücü bulundu |
| `10-ride.png` | Yolculukta |
| `11-arrived-rating.png` | Vardın: toplam tutar, ödeme ve yolculuk puanlama |
| `12-menu.png` | Menü |
| `13-trip-history.png` | Yolculuklarım (Trip History) |
| `14-account.png` | Hesabım (Account) |
| `15-payment-methods.png` | Ödeme yöntemleri (Payment Methods) |

Golden test dosyası aynı ekranın adını taşır (ör. `test/goldens/linux/05-home.png`). Böylece golden ile tasarım eşleşmesi addan bulunur.

## Tasarımla birebir alınmayacaklar

- Bazı ekranlarda logo görseli Stitch'te yüklenmemiş ve "Sarı Logo" yazısı görünüyor. Bu bir Stitch kusurudur; uygulamada logo yerine "Sarı" kelime markası kullanılır.
- Harita Stitch'te çizimdir. Uygulamada gerçek harita verisi kullanılır; harita karoları görsel karşılaştırmanın dışındadır.
- Sürücü fotoğrafları ve kart numaraları örnek veridir.
