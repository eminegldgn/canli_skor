import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 🎯 Doğrudan canlı site URL'si ile konuşan kütüphane
import 'dart:convert';

class MatchDetailScreen extends StatefulWidget {
  final String takim1;
  final String takim2;
  final String skor;
  final bool canliMi;
  final String matchId; // Canlı siteden veri çekebilmek için maç ID'sini ekledik

  const MatchDetailScreen({
    super.key,
    required this.takim1,
    required this.takim2,
    required this.skor,
    required this.canliMi,
    this.matchId = '1',
  });

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

// 🎨 SİTENİZDEKİ ÇAPRAZ KESİMİ YAPAN ÖZEL ÇİZİM SİHİRBAZI
class SkorbordKesiClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.46, size.height);
    path.lineTo(size.width * 0.54, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _MatchDetailScreenState extends State<MatchDetailScreen> with TickerProviderStateMixin {
late TabController _detailTabController;
final String _baseUrl = 'https://halisahafutbolligi.com';
bool _yukleniyor = false;

// Modellerden dinamik akacak canlı veri listelerimiz
List<dynamic> _canliOlaylar = [];
Map<String, dynamic> _canliKadrolar = {};
List<dynamic> _canliPerformanslar = [];

// 📡 CANLI VERİ MOTORU: MatchGamers ve MatchStatistics modellerini siteden paralel çeker
Future<void> _macDetaylariniSitedenCek() async {
setState(() => _yukleniyor = true);
try {
// 🎯 Sitenin resmi maç detay API kapısına istek atıyoruz
final response = await http.get(
Uri.parse('$_baseUrl/api/mac-detay/${widget.matchId}'),
headers: {
'Accept': 'application/json',
'X-Requested-With': 'XMLHttpRequest',
},
).timeout(const Duration(seconds: 10));

if (response.statusCode == 200) {
final gelenVeri = json.decode(response.body);
if (mounted) {
setState(() {
_canliOlaylar = gelenVeri['olaylar'] ?? [];
_canliKadrolar = gelenVeri['kadrolar'] ?? {}; // MatchGamers.php sütun verileri
_canliPerformanslar = gelenVeri['istatistikler'] ?? []; // MatchStatistics.php verileri
});
}
}
} catch (e) {
print("MAÇ DETAYI CANLI SİTEDEN ÇEKİLİRKEN HATA: $e");
}
if (mounted) setState(() => _yukleniyor = false);
}

@override
void initState() {
super.initState();
_detailTabController = TabController(length: 3, vsync: this);
_macDetaylariniSitedenCek();
}

@override
void dispose() {
_detailTabController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
List<String> skorParcalari = widget.skor.split('-');
String evSkor = skorParcalari.isNotEmpty ? skorParcalari[0].trim() : widget.skor;
String depSkor = skorParcalari.length > 1 ? skorParcalari[1].trim() : '';

return Scaffold(
backgroundColor: const Color(0xFFF4F6F9),
appBar: AppBar(
backgroundColor: const Color(0xFF212529),
iconTheme: const IconThemeData(color: Colors.white),
title: const Text('MAÇ DETAYI', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
centerTitle: true,
),
body: _yukleniyor
? const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
: Column(
children: [
// 🏆 SİTENİZDEKİ BİREBİR ÇAPRAZ KESİMLİ SKORBORD ALANI
Container(
width: double.infinity,
height: 160,
color: const Color(0xFFE53935),
child: Stack(
children: [
ClipPath(
clipper: SkorbordKesiClipper(),
child: Container(
width: double.infinity,
height: 160,
color: const Color(0xFF1E2125),
),
),
Padding(
padding: const EdgeInsets.symmetric(horizontal: 16.0),
child: Row(
children: [
Expanded(
child: Row(
mainAxisAlignment: MainAxisAlignment.end,
children: [
Expanded(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
const Icon(Icons.shield, color: Colors.white, size: 42),
const SizedBox(height: 6),
Text(widget.takim1, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
],
),
),
const SizedBox(width: 8),
Text(evSkor, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
const SizedBox(width: 16),
],
),
),
Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Text('-', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
if (widget.canliMi)
Container(
margin: const EdgeInsets.only(top: 4),
padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
child: const Text('CANLI', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
),
],
),
Expanded(
child: Row(
mainAxisAlignment: MainAxisAlignment.start,
children: [
const SizedBox(width: 16),
Text(depSkor, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
const SizedBox(width: 8),
Expanded(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
const Icon(Icons.shield, color: Colors.white, size: 42),
const SizedBox(height: 6),
Text(widget.takim2, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
],
),
),
],
),
),
],
),
),
],
),
),
// 🗂️ 3 SEKMELİ YENİ MENÜ ÇUBUĞU
Container(
color: const Color(0xFF212529),
child: TabBar(
controller: _detailTabController,
indicatorColor: Colors.white,
labelColor: Colors.white,
unselectedLabelColor: Colors.grey,
labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
tabs: const [
Tab(text: 'Maç Bilgisi'),
Tab(text: 'Kadro & Hakem'),
Tab(text: 'Karşılaştırma'),
],
),
),
Expanded(
child: TabBarView(
controller: _detailTabController,
children: [
// =========================================================
// ⏱️ 1. SEKME: MAÇ BİLGİSİ (MAÇ OLAYLARI + PERFORMANS KARTLARI)
// =========================================================
ListView(
padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
children: [
const Center(child: Text('MAÇ OLAYLARI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87, letterSpacing: 0.5))),
const SizedBox(height: 16),
// Eğer canlı veri geldiyse dikey zaman tünelini tıkır tıkır dolduruyor, yoksa yedek şablonu basıyor
if (_canliOlaylar.isNotEmpty)
..._canliOlaylar.map((olay) {
return _macOlayiSatiriOlustur(
dakika: "${olay['time'] ?? '0'}'",
olayText: olay['description'] ?? 'Olay',
isEvSahibi: olay['is_home'] ?? true,
ikon: olay['type'] == 'Kart' ? Icons.crop_portrait : Icons.sports_soccer,
ikonRenk: olay['type'] == 'Kart' ? Colors.amber.shade700 : Colors.blue.shade700,
);
})
else ...[
_macOlayiSatiriOlustur(
dakika: "15'",
olayText: "Mehmet Polat (0 - 1)",
isEvSahibi: false,
ikon: Icons.sports_soccer,
ikonRenk: Colors.blue.shade700,
),
_macOlayiSatiriOlustur(
dakika: "42'",
olayText: "Ali Gürbüz",
isEvSahibi: false,
ikon: Icons.crop_portrait,
ikonRenk: Colors.amber.shade700,
),
_macOlayiDevreArasiBandi("İY 0 - 1"),
_macOlayiSatiriOlustur(
dakika: "47'",
olayText: "Yalçın Kara (1 - 1)",
isEvSahibi: true,
ikon: Icons.sports_soccer,
ikonRenk: Colors.blue.shade700,
),
_macOlayiSatiriOlustur(
dakika: "49'",
olayText: "Mehmet Polat (1 - 2)",
isEvSahibi: false,
ikon: Icons.sports_soccer,
ikonRenk: Colors.blue.shade700,
),
_macOlayiDevreArasiBandi("MS 1 - 2"),
],
const SizedBox(height: 24),
const Divider(color: Colors.black12, thickness: 1),
const SizedBox(height: 16),
// 👑 SİTENİZDEKİ MAÇIN YILDIZLARI VE PERFORMANS KARTI (MatchStatistics.php model kurgusu)
const Text('MAÇIN ENLERİ & PERFORMANS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87, letterSpacing: 0.5)),
const SizedBox(height: 10),
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3))]),
child: Column(
children: [
_performansSatiriOlustur(Icons.emoji_events, Colors.amber.shade700, 'Maçın Oyuncusu (MVP):', 'Yakup Maral 👑'),
const SizedBox(height: 12),
const Divider(height: 1, color: Color(0xFFF4F6F9)),
const SizedBox(height: 12),
_performansSatiriOlustur(Icons.front_hand, Colors.blue.shade700, 'En Çok Kurtarış Yapan:', 'Caner (Altınorda FK) 🧤'),
const SizedBox(height: 12),
const Divider(height: 1, color: Color(0xFFF4F6F9)),
const SizedBox(height: 12),
_performansSatiriOlustur(Icons.workspace_premium, Colors.green.shade700, 'Maçın En Golcüsü:', 'Mehmet Polat (2 Gol) ⚽'),
],
),
),
],
),
// =========================================================
// 📋 2. SEKME: KADRO & HAKEM & TEKNİK DİREKTÖR ALANI
// =========================================================
ListView(
padding: const EdgeInsets.all(16.0),
children: [
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
child: const Row(
children: [
Icon(Icons.gavel, color: Color(0xFFE53935), size: 20),
SizedBox(width: 12),
Text('MAÇIN HAKEMİ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
SizedBox(width: 8),
Text('Ahmet Yılmaz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
],
),
),
const SizedBox(height: 16),
const Text('İLK 11 KADROLARI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87, letterSpacing: 0.5)),
const SizedBox(height: 8),
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// MatchGamers.php modelindeki gamer1...gamer11 alan adları dinamik olarak basılıyor
_oyuncuIsmiYaz(_canliKadrolar['gamer1'] ?? '1. Caner (K)'),
_oyuncuIsmiYaz(_canliKadrolar['gamer2'] ?? '3. Burak'),
_oyuncuIsmiYaz(_canliKadrolar['gamer3'] ?? '4. Mehmet'),
_oyuncuIsmiYaz(_canliKadrolar['gamer4'] ?? '7. Yalçın Kara'),
_oyuncuIsmiYaz(_canliKadrolar['gamer5'] ?? '8. Selim'),
_oyuncuIsmiYaz(_canliKadrolar['gamer6'] ?? '10. Hakan'),
_oyuncuIsmiYaz(_canliKadrolar['gamer7'] ?? '11. Gökhan'),
],
),
),
Container(width: 1, height: 150, color: Colors.black12),
const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
// MatchGamers.php modelindeki away1...away11 alan adları dinamik olarak basılıyor
_oyuncuIsmiYaz(_canliKadrolar['away1'] ?? '12. Volkan (K)'),
_oyuncuIsmiYaz(_canliKadrolar['away2'] ?? '2. Ali Gürbüz'),
_oyuncuIsmiYaz(_canliKadrolar['away3'] ?? '5. Mustafa'),
_oyuncuIsmiYaz(_canliKadrolar['away4'] ?? '9. Mehmet Polat'),
_oyuncuIsmiYaz(_canliKadrolar['away5'] ?? '14. Serkan'),
_oyuncuIsmiYaz(_canliKadrolar['away6'] ?? '17. Emre'),
_oyuncuIsmiYaz(_canliKadrolar['away7'] ?? '20. Oğuzhan'),
],
),
),
],
),
),
const SizedBox(height: 16),
const Text('TEKNİK DİREKTÖRLER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87, letterSpacing: 0.5)),
const SizedBox(height: 8),
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
child: const Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('Fatih Terim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
Icon(Icons.person, color: Colors.grey, size: 20),
Text('Jose Mourinho', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
],
),
),
],
),
// =========================================================
// 📊 3. SEKME: KARŞILAŞTIRMA (FORM DURUMU VE GEÇMİŞ MAÇLAR)
// =========================================================
ListView(
padding: const EdgeInsets.all(16.0),
children: [
const Text('TAKIM FORM DURUMLARI (SON 5 MAÇ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
const SizedBox(height: 8),
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
child: Column(
children: [
_formDurumuSatiriOlustur('Ev Sahibi', ['G', 'G', 'B', 'M', 'G']),
const SizedBox(height: 12),
const Divider(height: 1, color: Color(0xFFF0F0F0)),
const SizedBox(height: 12),
_formDurumuSatiriOlustur('Deplasman', ['M', 'G', 'B', 'G', 'M']),
],
),
),
  const SizedBox(height: 24),
  const Text('ARALARINDAKİ SON MAÇLAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
  const SizedBox(height: 8),
  Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
    child: Column(
      children: [
        _gecmisMacSatiriOlustur('21/07/26', '0 - 1'),
        _gecmisMacSatiriOlustur('18/03/25', '2 - 2'),
        _gecmisMacSatiriOlustur('12/11/24', '1 - 3'),
        _gecmisMacSatiriOlustur('05/05/24', '0 - 0'),
      ],
    ),
  ),
],
),
],
),
),
],
),
);
}

  Widget _oyuncuIsmiYaz(String isim) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(isim, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
    );
  }

  Widget _performansSatiriOlustur(IconData ikon, Color ikonRenk, String baslik, String deger) {
    return Row(
      children: [
        Icon(ikon, color: ikonRenk, size: 20),
        const SizedBox(width: 12),
        Text(baslik, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(width: 6),
        Expanded(child: Text(deger, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _formDurumuSatiriOlustur(String takimTipi, List<String> sonBesMac) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(takimTipi, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
        Row(
          children: sonBesMac.map((sonuc) {
            Color halkaRengi = Colors.grey;
            if (sonuc == 'G') halkaRengi = Colors.green.shade600;
            if (sonuc == 'M') halkaRengi = Colors.red.shade600;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 22,
              height: 22,
              decoration: BoxDecoration(color: halkaRengi, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(sonuc, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _gecmisMacSatiriOlustur(String tarih, String skor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 0.5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tarih, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(widget.takim1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(4)),
            child: Text(skor, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          Text(widget.takim2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _macOlayiSatiriOlustur({
    required String dakika,
    required String olayText,
    required bool isEvSahibi,
    required IconData ikon,
    required Color ikonRenk,
  }) {
    return Row(
      children: [
        Expanded(
          child: isEvSahibi
              ? Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF212529).withOpacity(0.04), borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(olayText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Icon(ikon, size: 16, color: ikonRenk),
              ],
            ),
          )
              : const SizedBox(),
        ),
        Column(
          children: [
            Container(width: 2, height: 15, color: Colors.black26),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE53935), width: 1.5)),
              child: Text(dakika, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
            ),
            Container(width: 2, height: 15, color: Colors.black26),
          ],
        ),
        Expanded(
          child: !isEvSahibi
              ? Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF212529).withOpacity(0.04), borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                Icon(ikon, size: 16, color: ikonRenk),
                const SizedBox(width: 8),
                Text(olayText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          )
              : const SizedBox(),
        ),
      ],
    );
  }

  Widget _macOlayiDevreArasiBandi(String baslik) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.black12, thickness: 1)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFF212529), borderRadius: BorderRadius.circular(20)),
          child: Text(baslik, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const Expanded(child: Divider(color: Colors.black12, thickness: 1)),
      ],
    );
  }
}


