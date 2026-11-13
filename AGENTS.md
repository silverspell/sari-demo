# AGENTS.md

Sarı, Türkçe bir taksi çağırma demo uygulamasıdır (Flutter, iOS ve Android). Backend yoktur: giriş, sürücü, rota, ücret ve ödeme uygulama içinde sahte veridir. Harita gerçek harita verisiyle çizilir.

## Proje

- Flutter 3.41.9 (Dart 3.11). Sürüm `.devcontainer/devcontainer.json` imajında sabittir.
- Uygulama metinleri Türkçedir. Türkçe karakterler (ç, ğ, ı, İ, ö, ş, ü) doğru yazılır.
- Paket adı `sari`, uygulama kimliği `tr.byteflow.sari`.
- Tasarım sistemi `docs/design/DESIGN.md`; renkler, tipografi, köşe ve boşluk değerleri `lib/theme/sari_theme.dart` içindedir. Ekranlarda renk ve font sabiti yazılmaz, temadan okunur.

## Dizinler

- `lib/`: uygulama kodu.
- `test/`: widget ve golden testleri. Golden çıktıları `test/goldens/linux/` altındadır.
- `docs/design/screens/`: Stitch'ten alınan ekran tasarımları (PNG). Adlandırma `docs/design/README.md` içindedir.
- `.maestro/`: uçtan uca demo akışı.

## Test

- Odaklı çalıştırma: `flutter test test/<dosya>_test.dart`.
- Tüm suite: `flutter analyze` ve `flutter test`.
- Golden'lar `alchemist` ile, gerçek fontla (Inter, `assets/fonts/`) ve yalnız Linux'ta üretilir; macOS'ta golden testleri atlanır. CI modu kapalıdır çünkü metni bloğa çevirir ve görsel kontrolde metin okunamaz. Güncellemek için devcontainer içinde: `flutter test --update-goldens <dosya>`.
- Her ekranın en az bir golden'ı vardır ve adı tasarım dosyasıyla aynıdır (ör. `05-home.png`).
- Testler ağa çıkmaz: harita testte yerel/sahte karo kullanır, konum sabittir, taksi hareketi sabit seed ile üretilir.

## Kodlama

- Ekranlar taşmaz, kesilmez, üst üste binmez; küçük ve büyük iPhone boyutlarında golden alınır.
- Ödeme yöntemlerinde kart ekleme formu yoktur.
- Konum izni verilmezse varsayılan konum kullanılır.
