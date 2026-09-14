import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 🎯 Burmadaki tırnak ve uzantı hatası jilet gibi düzeltildi!
import 'dart:convert'; // 🎯 Gelen canlı skorları çözmek için JSON kitaplığı bağlandı
import 'dart:async'; // 🎯 5 saniyede bir skoru tazeleyecek zamanlayıcı (Timer) için bağlandı
import 'match_detail_screen.dart'; // 🎯 Detay sayfasına geçiş için en üstte bağladık
import 'teams_screen.dart';
import 'transfers_screen.dart';
import 'punishments_screen.dart';
import 'statistics_screen.dart';

class DashboardScreen extends StatefulWidget {
  final List<dynamic> canliMaclar;
  final List<dynamic> puanDurumu;
  final List<dynamic> oyuncular;

  const DashboardScreen({
    super.key,
    this.canliMaclar = const [],
    this.puanDurumu = const [],
    this.oyuncular = const [],
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
final ScrollController _scrollController = ScrollController();
late TabController _istatistikTabController;
Timer? _canliYenilemeZamanlayicisi; // 🎯 Arka planda sessizce çalışacak zamanlayıcı amirimiz

String _seciliTarih = 'CUM 24/07';
String _seciliFiltre = 'Tümü';
int _aktifAltSekme = 0;

final Set<String> _favoriMaclar = {};

// 🎯 GÜNCELLENDİ: İnternet sitesinden gelecek olan anlık canlı maç verilerini tutacak dinamik listelerimiz
List<dynamic> _guncelMaclar = [];
List<dynamic> _guncelPuanDurumu = [];

@override
void initState() {
super.initState();
_istatistikTabController = TabController(length: 4, vsync: this);

// İlk açılışta Login ekranından gelen o hazır dev veri paketlerini listelerimize dolduruyoruz
_guncelMaclar = widget.canliMaclar;
_guncelPuanDurumu = widget.puanDurumu;

// 🎯 DÜZELTİLDİ: İllegal karakter '304' hatasına sebep olan Türkçe büyük İ harfi tamamen temizlendi!
_canliYenilemeZamanlayicisi = Timer.periodic(const Duration(seconds: 5), (timer) {
_canliVerileriInternettenCek();
});
}

  // 📡 İNTERNET SİTESİNDEN SKORLARI ÇEKEN RESMİ GET İSTEĞİ FONKSİYONU
  Future<void> _canliVerileriInternettenCek() async {
    try {
      // 🎯 Doğrudan sitenin tüm bilgileri ve canlı maçları dönen ana kapısı!
      final maclarCevap = await http.get(
        Uri.parse('https://halisahafutbolligi.com'),
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 10));

      print("DASHBOARD CANLI MAÇ İSTEĞİ DURUM KODU: ${maclarCevap.statusCode}");

      if (maclarCevap.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _guncelMaclar = json.decode(maclarCevap.body);
        });
      }
    } catch (hata) {
      print("DASHBOARD CANLI VERİ ÇEKME HATASI: $hata");
    }
  }

@override
void dispose() {
_canliYenilemeZamanlayicisi?.cancel(); // Sayfadan çıkıldığında telefonun bataryasını yememesi için zamanlayıcıyı kapatıyoruz
_scrollController.dispose();
_istatistikTabController.dispose();
super.dispose();
}

void _enUsteGit() {
_scrollController.animateTo(
0.0,
duration: const Duration(milliseconds: 500),
curve: Curves.easeOut,
);
}

void _favoriDurumunuDegistir(String macId, String takimlar) {
setState(() {
if (_favoriMaclar.contains(macId)) {
_favoriMaclar.remove(macId);
} else {
_favoriMaclar.add(macId);
}
});
}
// 🎯 DÜZELTİLDİ: Eksik olan takvimi açma fonksiyonu jilet gibi tam yerine eklendi!
Future<void> _takvimiAc(BuildContext context) async {
final DateTime? secilen = await showDatePicker(
context: context,
initialDate: DateTime.now(),
firstDate: DateTime(2025),
lastDate: DateTime(2030),
builder: (context, child) {
return Theme(
data: Theme.of(context).copyWith(
colorScheme: const ColorScheme.light(primary: Color(0xFFE53935), onPrimary: Colors.white, onSurface: Colors.black87),
),
child: child!,
);
},
);
if (secilen != null) {
setState(() {
_seciliTarih = "${secilen.day}/${secilen.month}/${secilen.year}";
});
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF4F6F9),
appBar: AppBar(
backgroundColor: const Color(0xFF212529),
elevation: 0,
automaticallyImplyLeading: false,
title: GestureDetector(
onTap: _enUsteGit,
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Image.asset('assets/logo.png', height: 35),
const SizedBox(width: 10),
const Text('HFL CANLI', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
],
),
),
centerTitle: false,
actions: [IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {})],
),
body: _aktifAltSekme == 1
? _istatistikPaneliEkrani()
: Column(
children: [
Container(
color: const Color(0xFF212529),
padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
child: Row(
children: [
const Icon(Icons.chevron_left, color: Colors.white60),
Expanded(
child: SingleChildScrollView(
scrollDirection: Axis.horizontal,
child: Row(
children: [
_tarihSecenegi('SAL 21/07'),
_tarihSecenegi('CAR 22/07'),
_tarihSecenegi('PER 23/07'),
_tarihSecenegi('CUM 24/07'),
_tarihSecenegi('CTS 25/07'),
_tarihSecenegi('PAZ 26/07'),
],
),
),
),
const Icon(Icons.chevron_right, color: Colors.white60),
const SizedBox(width: 4),
GestureDetector(
onTap: () => _takvimiAc(context),
child: const Padding(
padding: EdgeInsets.symmetric(horizontal: 8.0),
child: Icon(Icons.calendar_month, color: Colors.white, size: 22),
),
),
],
),
),
Container(
color: Colors.white,
padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
child: Row(
children: [
Expanded(child: _filtreButonu('Tümü')),
const SizedBox(width: 10),
Expanded(child: _filtreButonu('Canlı')),
const SizedBox(width: 10),
Expanded(child: _filtreButonu('Bitenler')),
],
),
),
const Divider(height: 1, color: Color(0xFFE5E5E5)),
Expanded(
child: ListView(
controller: _scrollController,
padding: EdgeInsets.zero,
children: [
Padding(
padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
child: SingleChildScrollView(
scrollDirection: Axis.horizontal,
physics: const BouncingScrollPhysics(),
child: Row(
children: [
_hizliMenuButonu('🛡️ Takımlar', const Color(0xFF212529), () {
Navigator.push(context, MaterialPageRoute(builder: (context) => const TeamsScreen()));
}),
const SizedBox(width: 8),
_hizliMenuButonu('🚀 Transferler', const Color(0xFF212529), () {
Navigator.push(context, MaterialPageRoute(builder: (context) => const TransfersScreen()));
}),
const SizedBox(width: 8),
_hizliMenuButonu('🟨 Cezalar', const Color(0xFF212529), () {
Navigator.push(context, MaterialPageRoute(builder: (context) => const PunishmentsScreen()));
}),
const SizedBox(width: 8),
_hizliMenuButonu('📊 İstatistikler', const Color(0xFFE53935), () {
Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()));
}),
],
),
),
),
_ligBasligiOlustur('🏆 SERIE A MÜSABAKALARI'),
if (_seciliFiltre == 'Tümü' || _seciliFiltre == 'Canlı') ...[
_macSatiriOlustur('m1', '21:00', 'Altınorda FK', 'Beypazarı Tanrıverdi', '2 - 1', true),
_macSatiriOlustur('m2', '22:30', 'Prison FC', 'Gençlik Gücü', '0 - 0', true),
_macSatiriOlustur('m3', '20:30', 'Dragon FC', 'Anadolu FK', '0 - 0', true),
_macSatiriOlustur('m4', '22:00', 'EDIM F.C', 'KADIKIRAN FC', '1 - 1', true),
],
if (_seciliFiltre == 'Tümü' || _seciliFiltre == 'Bitenler') ...[
_macSatiriOlustur('m5', 'MS', '06 ANKARAGÜCÜ', 'FELLAS', '3 - 2', false),
_macSatiriOlustur('m6', 'MS', 'Elhamra spor', 'OLD BOYS', '2 - 0', false),
],
if (_seciliFiltre == 'Tümü') ...[
_macSatiriOlustur('m9', '19:00', 'Diriliş Fk', 'BOZOK FC', '3 - 4', false),
_macSatiriOlustur('m10', '23:59', 'ANKA FC', 'BOĞALAR', '- ', false),
],
_ligBasligiOlustur('🥈 SERIE B MÜSABAKALARI'),
if (_seciliFiltre == 'Tümü' || _seciliFiltre == 'Bitenler') ...[
_macSatiriOlustur('m7', 'MS', 'Nova prime', 'IMAGINE DRAGONS', '0 - 2', false),
_macSatiriOlustur('m8', 'MS', 'Avengers', 'Orhan Aspava FK', '5 - 3', false),
],
_ligBasligiOlustur('🥉 SERIE C MÜSABAKALARI'),
if (_seciliFiltre == 'Tümü' || _seciliFiltre == 'Canlı') ...[
_macSatiriOlustur('m11', '18:30', 'Oğultürk Pano', 'BlackMarten', '1 - 1', true),
_macSatiriOlustur('m12', '22:00', 'Bartınspor', 'Ayhan Işık E.K.', '4 - 4', true),
],
if (_seciliFiltre == 'Tümü' || _seciliFiltre == 'Bitenler') ...[
_macSatiriOlustur('m13', 'MS', 'Çayyolu İ.Y.', 'Altındağspor', '2 - 0', false),
_macSatiriOlustur('m14', 'MS', 'Juvendost', 'Yedi Mart SK', '1 - 2', false),
],
if (_seciliFiltre == 'Tümü') ...[
_macSatiriOlustur('m15', '20:45', 'Toprak Ticaret', 'Kurumsal United', 'MS', false),
_macSatiriOlustur('m16', '21:15', 'Batı Juniors', 'Night Fever FC', '- ', false),
_macSatiriOlustur('m17', '23:45', 'Fastyoungs FC', 'Dragon FC', 'MS', false),
],

if (_guncelMaclar.isNotEmpty) ...[
_ligBasligiOlustur('📡 VERİTABANINDAN CANLI MAÇLAR'),
..._guncelMaclar.asMap().entries.map((entry) {
int index = entry.key;
var mac = entry.value;

String id = (mac['id'] ?? index).toString();
String saat = mac['date'] ?? 'Canlı';

String evSahibi = mac['team1_detail'] != null ? mac['team1_detail']['team_name'] : "Takım ${mac['team1']}";
String deplasman = mac['team2_detail'] != null ? mac['team2_detail']['team_name'] : "Takım ${mac['team2']}";

String skor = "${mac['home_score'] ?? 0} - ${mac['away_score'] ?? 0}";

bool canliMi = mac['status'] == 'canli';

if (_seciliFiltre == 'Canlı' && !canliMi) return const SizedBox.shrink();
if (_seciliFiltre == 'Bitenler' && canliMi) return const SizedBox.shrink();

return _macSatiriOlustur(id, saat, evSahibi, deplasman, skor, canliMi);
}).toList(),
],
],
),
),
],
),
bottomNavigationBar: BottomNavigationBar(
currentIndex: _aktifAltSekme,
backgroundColor: Colors.white,
selectedItemColor: const Color(0xFFE53935),
unselectedItemColor: Colors.grey,
onTap: (index) {
setState(() {
_aktifAltSekme = index;
});
},
items: const [
BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Canlı Skor'),
BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Puan Durumu'),
],
),
);
}

Widget _istatistikPaneliEkrani() {
return Column(
children: [
Container(
color: const Color(0xFF212529),
child: TabBar(
controller: _istatistikTabController,
indicatorColor: const Color(0xFFE53935),
labelColor: Colors.white,
unselectedLabelColor: Colors.grey,
isScrollable: true,
tabs: const [
Tab(text: 'Puan Durumu'),
Tab(text: 'Oyuncular'),
Tab(text: 'Gol Kralligi'),
Tab(text: 'Asist Kralligi'),
],
),
),
Expanded(
child: TabBarView(
controller: _istatistikTabController,
children: [
ListView(
children: [
_puanDurumuUstBilgiBandi(),
if (_guncelPuanDurumu.isNotEmpty)
..._guncelPuanDurumu.asMap().entries.map((entry) {
int idx = entry.key;
var veri = entry.value;
return _puanDurumuSatiriOlustur(
(idx + 1).toString(),
veri['team_name'] ?? 'Bilinmeyen Takım',
(veri['oynanan'] ?? 0).toString(),
(veri['galibiyet'] ?? 0).toString(),
(veri['beraberlik'] ?? 0).toString(),
(veri['maglubiyet'] ?? 0).toString(),
(veri['puan'] ?? 0).toString(),
);
}).toList()
else ...[
_puanDurumuSatiriOlustur('1', 'Yedi Mart SK', '5', '5', '0', '0', '15'),
_puanDurumuSatiriOlustur('2', 'Orhan Aspava FK', '5', '4', '1', '0', '13'),
_puanDurumuSatiriOlustur('3', 'Altindagspor', '5', '4', '0', '1', '12'),
_puanDurumuSatiriOlustur('4', 'Toprak Ticaret', '4', '3', '1', '0', '10'),
_puanDurumuSatiriOlustur('5', 'Bati Juniors', '4', '2', '0', '2', '6'),
_puanDurumuSatiriOlustur('6', 'Fastyoungs Fc', '1', '1', '0', '0', '3'),
_puanDurumuSatiriOlustur('7', 'FELLAS', '3', '1', '0', '2', '3'),
_puanDurumuSatiriOlustur('8', 'Beypazari Tanriverdi', '5', '1', '0', '4', '3'),
],
],
),
_sadeOyuncuListesiEkrani(),
ListView(
children: [
_tabloUstBilgiBandi('Sira', 'Oyuncu / Takim', 'Gol'),
_oyuncuSatiriOlustur('1', 'YAKUP MARAL', 'Dirilis Fk', '8'),
_oyuncuSatiriOlustur('2', 'Berke USTUN', '06 ANKARAGUCÜ', '8'),
_oyuncuSatiriOlustur('3', 'Ozkan Oner', 'Altindagspor', '7'),
_oyuncuSatiriOlustur('4', 'Harun Alparslan', 'BlackMarten', '7'),
_oyuncuSatiriOlustur('5', 'ERTUGRUL FURKAN', 'BOGALAR', '6'),
_oyuncuSatiriOlustur('6', 'Musa Yuksel', 'Orhan Aspava FK', '6'),
],
),
ListView(
children: [
_tabloUstBilgiBandi('Sira', 'Oyuncu / Takim', 'Asist'),
_oyuncuSatiriOlustur('1', 'Berke USTUN', '06 ANKARAGUCÜ', '6'),
_oyuncuSatiriOlustur('2', 'YAKUP MARAL', 'Dirilis Fk', '5'),
_oyuncuSatiriOlustur('3', 'Harun Alparslan', 'BlackMarten', '5'),
],
),
],
),
),
],
);
}
Widget _puanDurumuUstBilgiBandi() {
return Container(
color: const Color(0xFFE53935),
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
child: const Row(
children: [
SizedBox(width: 30, child: Text('#', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
Expanded(child: Text('TAKIM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
SizedBox(width: 25, child: Text('O', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
SizedBox(width: 25, child: Text('G', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
SizedBox(width: 25, child: Text('B', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
SizedBox(width: 25, child: Text('M', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
SizedBox(width: 35, child: Text('P', textAlign: TextAlign.end, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
],
),
);
}

Widget _puanDurumuSatiriOlustur(String sira, String takim, String o, String g, String b, String m, String p) {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5))),
child: Row(
children: [
SizedBox(width: 30, child: Text(sira, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13))),
Expanded(child: Text(takim, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
SizedBox(width: 25, child: Text(o, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 13))),
SizedBox(width: 25, child: Text(g, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 13))),
SizedBox(width: 25, child: Text(b, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 13))),
SizedBox(width: 25, child: Text(m, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 13))),
SizedBox(width: 35, child: Text(p, textAlign: TextAlign.end, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14))),
],
),
);
}
Widget _tabloUstBilgiBandi(String col1, String col2, String col3) {
return Container(
color: const Color(0xFFE53935),
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
child: Row(
children: [
SizedBox(width: 40, child: Text(col1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
Expanded(child: Text(col2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
SizedBox(width: 40, child: Text(col3, textAlign: TextAlign.end, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
],
),
);
}

Widget _oyuncuTabloUstBilgiBandi() {
return Container(
color: const Color(0xFFE53935),
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
child: const Row(
children: [
SizedBox(width: 40, child: Text('Sira', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
SizedBox(width: 16),
Expanded(child: Text('Oyuncu / Takim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
],
),
);
}

Widget _oyuncuSatiriOlustur(String sira, String oyuncu, String takim, String deger) {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5))),
child: Row(
children: [
SizedBox(width: 40, child: Text(sira, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13))),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(oyuncu, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
Text(takim, style: const TextStyle(color: Colors.grey, fontSize: 11)),
],
),
),
SizedBox(width: 40, child: Text(deger, textAlign: TextAlign.end, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14))),
],
),
);
}

Widget _sadeOyuncuListesiEkrani() {
return ListView(
padding: EdgeInsets.zero,
children: [
_oyuncuTabloUstBilgiBandi(),
if (widget.oyuncular.isNotEmpty)
...widget.oyuncular.asMap().entries.map((entry) {
int idx = entry.key;
var veri = entry.value;
return _sadeOyuncuKartiOlustur(
(idx + 1).toString(),
veri['member_name'] ?? 'Gizli Oyuncu',
veri['takimi'] ?? 'Serbest Oyuncu',
);
}).toList()
else ...[
_sadeOyuncuKartiOlustur('1', 'Bekir Demir', 'Dirilis Fk'),
_sadeOyuncuKartiOlustur('2', 'Burak Çelik', '06 ANKARAGUCU'),
_sadeOyuncuKartiOlustur('3', 'mert ak', 'BlackMarten'),
_sadeOyuncuKartiOlustur('4', 'Ali Akbulut', 'Altindagspor'),
_sadeOyuncuKartiOlustur('5', 'Mehmet Polat', 'BOGALAR'),
_sadeOyuncuKartiOlustur('6', 'Aşkın Tuykar', 'Orhan Aspava FK'),
],
],
);
}
  Widget _sadeOyuncuKartiOlustur(String sira, String ad, String takim) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(sira, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ad, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(takim, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarihSecenegi(String gunText) {
    bool isSecili = _seciliTarih == gunText;
    return GestureDetector(
      onTap: () {
        setState(() {
          _seciliTarih = gunText;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: isSecili ? const Color(0xFFE53935) : Colors.transparent, borderRadius: BorderRadius.circular(4)),
        child: Text(gunText, style: TextStyle(color: isSecili ? Colors.white : Colors.white70, fontSize: 11)),
      ),
    );
  }

  Widget _filtreButonu(String filtreAdi) {
    bool isSecili = _seciliFiltre == filtreAdi;
    return GestureDetector(
      onTap: () {
        setState(() {
          _seciliFiltre = filtreAdi;
        });
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSecili ? const Color(0xFFEFEFEF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSecili ? Colors.black87 : const Color(0xFFE5E5E5)),
        ),
        child: Text(filtreAdi, style: TextStyle(color: isSecili ? Colors.black87 : Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _ligBasligiOlustur(String ligAdi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.only(top: 6),
      color: const Color(0xFFF4F6F9),
      child: Text(ligAdi, style: const TextStyle(color: Color(0xFF212529), fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _hizliMenuButonu(String yazi, Color renk, VoidCallback tiklama) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: renk,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: tiklama,
        child: Text(yazi, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
      ),
    );
  }

  Widget _macSatiriOlustur(String macId, String saat, String takim1, String takim2, String skor, bool canliMi) {
    bool isFavori = _favoriMaclar.contains(macId);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailScreen(
              takim1: takim1,
              takim2: takim2,
              skor: skor,
              canliMi: canliMi,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFECEFF1), width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 62,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    saat,
                    style: TextStyle(
                      color: canliMi ? const Color(0xFFE53935) : Colors.black54,
                      fontWeight: canliMi ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  if (canliMi) ...[
                    const SizedBox(width: 4),
                    const Text('•', style: TextStyle(color: Color(0xFFE53935), fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Text(
                takim1,
                textAlign: TextAlign.end,
                style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                skor,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: canliMi ? const Color(0xFFE53935) : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Text(
                takim2,
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _favoriDurumunuDegistir(macId, '$takim1 - $takim2'),
              child: Icon(
                isFavori ? Icons.star : Icons.star_border,
                color: isFavori ? const Color(0xFFE53935) : Colors.black12,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
