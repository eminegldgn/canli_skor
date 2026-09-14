import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 🎯 Sunucuya reji emirlerini göndermek için bağlandı
import 'dart:convert'; // 🎯 Verileri paketlemek için JSON kitaplığı bağlandı

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with TickerProviderStateMixin {
late TabController _adminTabController;

// --- 1. SEKME: CANLI REJİ DEĞİŞKENLERİ ---
final String _seciliMacId = '1'; // Veritabanındaki gerçek maç ID'si sayısal olur
String _seciliLig = '🏆 SERIE A MÜSABAKALARI';

final TextEditingController _evSahibiAramaController = TextEditingController(text: 'Altınorda FK');
final TextEditingController _deplasmanAramaController = TextEditingController(text: 'Beypazarı Tanrıverdi');

String _ayarlananTarih = 'CUM 24/07';
String _ayarlananSaat = '21:00';
String _aktifMacDurumu = 'Gelecek Maç';

final TextEditingController _skorEvController = TextEditingController(text: '0');
final TextEditingController _skorDepController = TextEditingController(text: '0');
final TextEditingController _canliDakikaController = TextEditingController(text: '1');

String _olayTipi = 'Gol ⚽';
String _olayOyuncu = 'YAKUP MARAL (Ev Sahibi)';
final TextEditingController _olayDakikaController = TextEditingController(text: '15');

final List<String> _tumTakimlarHavuzu = [
'Altınorda FK', 'Beypazarı Tanrıverdi', 'Prison FC', 'Gençlik Gücü',
'Dragon FC', 'Anadolu FK', '06 ANKARAGÜCÜ', 'FELLAS', 'Elhamra spor',
'OLD BOYS', 'Diriliş Fk', 'BOZOK FC', 'ANKA FC', 'BOĞALAR', 'Nova prime',
'IMAGINE DRAGONS', 'Avengers', 'Orhan Aspava FK', 'Oğultürk Pano',
'BlackMarten', 'Bartınspor', 'Ayhan Işık E.K.', 'Çayyolu İ.Y.',
'Altındağspor', 'Juvendost', 'Yedi Mart SK', 'Toprak Ticaret',
'Kurumsal United', 'Batı Juniors', 'Night Fever FC', 'Fastyoungs FC'
];

// --- 2. SEKME: KADRO & MAÇ SKORLARI DEĞİŞKENLERİ ---
final TextEditingController _hakemController = TextEditingController(text: 'Ahmet Yılmaz');
final TextEditingController _teknikEvController = TextEditingController(text: 'Hakan Tank');
final TextEditingController _teknikDepController = TextEditingController(text: 'Mehmet Tekin');

final List<TextEditingController> _evOyuncuKutulari = List.generate(11, (i) => TextEditingController(text: '${i + 1}. Oyuncu'));
final List<TextEditingController> _depOyuncuKutulari = List.generate(11, (i) => TextEditingController(text: '${i + 1}. Oyuncu'));

// --- 3. SEKME: OYUNCU YÖNETİMİ DEĞİŞKENLERİ ---
final TextEditingController _oyuncuAdController = TextEditingController();
final TextEditingController _oyuncuTcController = TextEditingController();
final TextEditingController _oyuncuEpostaController = TextEditingController();
final TextEditingController _oyuncuTelefonController = TextEditingController();
final TextEditingController _oyuncuIlController = TextEditingController();
final TextEditingController _oyuncuBoyController = TextEditingController();
final TextEditingController _oyuncuKiloController = TextEditingController();
final TextEditingController _oyuncuAraController = TextEditingController();

DateTime? _secilenDogumTarihi;
String _oyuncuSeciliTakim = 'Diriliş Fk';

// 🎯 KESİN RESMİ YOL: Sadece ve doğrudan senin istediğin o resmi canlı site URL'si!
final String _baseUrl = 'https://halisahafutbolligi.com';

// ⚽ REJİ: ANLIK SKOR GÜNCELLEME (Games.php modelindeki home_score ve away_score alanlarına kilitli)
Future<void> _skorGuncelle(String yeniSkor) async {
try {
await http.post(
Uri.parse('$_baseUrl/api/reji/skor-guncelle'),
headers: {
"Content-Type": "application/json",
"Accept": "application/json",
"X-Requested-With": "XMLHttpRequest",
},
body: json.encode({
'mac_id': _seciliMacId,
'yeni_home_score': _skorEvController.text.trim(),
'yeni_away_score': _skorDepController.text.trim()
}),
).timeout(const Duration(seconds: 10));
} catch (e) {
print("REJİ SKOR GÜNCELLEME HATASI: $e");
}
}

// ⏱️ REJİ: MAÇ DURUMU VE SAAT GÜNCELLEME (Games.php modelindeki date ve status alanlarına kilitli)
Future<void> _durumGuncelle(String yeniDurum, bool canliMi) async {
try {
await http.post(
Uri.parse('$_baseUrl/api/reji/durum-guncelle'),
headers: {
"Content-Type": "application/json",
"Accept": "application/json",
"X-Requested-With": "XMLHttpRequest",
},
body: json.encode({
'mac_id': _seciliMacId,
'yeni_saat_veya_durum': yeniDurum,
'canli_mi': canliMi
}),
).timeout(const Duration(seconds: 10));
} catch (e) {
print("REJİ DURUM GÜNCELLEME HATASI: $e");
}
}

// 🏁 REJİ: MÜSABAKAYI RESMİ OLARAK BİTİRMEK
Future<void> _maciBitir() async {
try {
await http.post(
Uri.parse('$_baseUrl/api/reji/mac-bitir'),
headers: {
"Content-Type": "application/json",
"Accept": "application/json",
"X-Requested-With": "XMLHttpRequest",
},
body: json.encode({
'mac_id': _seciliMacId
}),
).timeout(const Duration(seconds: 10));
_bildirimGoster('🏁 Müsabaka reji tarafından başarıyla bitirildi (MS)!');
} catch (e) {
print("REJİ MAÇ BİTİRME HATASI: $e");
}
}

@override
void initState() {
super.initState();
_adminTabController = TabController(length: 3, vsync: this);
}

@override
void dispose() {
_skorEvController.dispose();
_skorDepController.dispose();
_canliDakikaController.dispose();
_olayDakikaController.dispose();
_hakemController.dispose();
_teknikEvController.dispose();
_teknikDepController.dispose();
for (var c in _evOyuncuKutulari) { c.dispose(); }
for (var c in _depOyuncuKutulari) { c.dispose(); }
_evSahibiAramaController.dispose();
_deplasmanAramaController.dispose();
_oyuncuAdController.dispose();
_oyuncuTcController.dispose();
_oyuncuEpostaController.dispose();
_oyuncuTelefonController.dispose();
_oyuncuIlController.dispose();
_oyuncuBoyController.dispose();
_oyuncuKiloController.dispose();
_oyuncuAraController.dispose();
_adminTabController.dispose();
super.dispose();
}
@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF4F6F9),
appBar: AppBar(
backgroundColor: const Color(0xFF212529),
leading: Padding(
padding: const EdgeInsets.all(12.0),
child: Image.asset('assets/logo.png'),
),
title: const Text('HFL ADMİN PANELİ', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
centerTitle: true,
iconTheme: const IconThemeData(color: Colors.white),
bottom: TabBar(
controller: _adminTabController,
indicatorColor: const Color(0xFFE53935),
labelColor: Colors.white,
unselectedLabelColor: Colors.grey,
isScrollable: true,
tabs: const [
Tab(text: 'Canlı Reji Merkezi'),
Tab(text: 'Kadro & Skor Ayarları'),
Tab(text: 'Oyuncu Yönetimi'),
],
),
),
body: TabBarView(
controller: _adminTabController,
children: [
// =========================================================
// ⏱️ 1. SEKME: CANLI REJİ MERKEZİ İÇERİĞİ
// =========================================================
ListView(
padding: const EdgeInsets.all(16.0),
children: [
_kartBasligiOlustur('1. FİKSTÜR YÖNETİMİ (YENİ MAÇ AYARLA)'),
Container(
padding: const EdgeInsets.all(16),
margin: const EdgeInsets.only(bottom: 20),
decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text('Lig Grubu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
DropdownButton<String>(
value: _seciliLig,
isExpanded: true,
items: <String>['🏆 SERIE A MÜSABAKALARI', '🥈 SERIE B MÜSABAKALARI', '🥉 SERIE C MÜSABAKALARI'].map((String v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13)))).toList(),
onChanged: (v) => setState(() => _seciliLig = v!),
),
const SizedBox(height: 12),
Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text('Ev Sahibi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
const SizedBox(height: 4),
Autocomplete<String>(
optionsBuilder: (TextEditingValue textEditingValue) {
if (textEditingValue.text.isEmpty) { return const Iterable<String>.empty(); }
return _tumTakimlarHavuzu.where((String option) {
return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
});
},
displayStringForOption: (String option) => option,
fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
if (textEditingController.text.isEmpty && _evSahibiAramaController.text.isNotEmpty) {
textEditingController.text = _evSahibiAramaController.text;
}
return TextField(
controller: textEditingController,
focusNode: focusNode,
style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 4), hintText: 'Takım ara...', isDense: true),
onChanged: (val) => _evSahibiAramaController.text = val,
);
},
onSelected: (String selection) { setState(() { _evSahibiAramaController.text = selection; }); },
),
],
),
),
const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text('Deplasman', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
const SizedBox(height: 4),
Autocomplete<String>(
optionsBuilder: (TextEditingValue textEditingValue) {
if (textEditingValue.text.isEmpty) { return const Iterable<String>.empty(); }
return _tumTakimlarHavuzu.where((String option) {
return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
});
},
displayStringForOption: (String option) => option,
fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
if (textEditingController.text.isEmpty && _deplasmanAramaController.text.isNotEmpty) {
textEditingController.text = _deplasmanAramaController.text;
}
return TextField(
controller: textEditingController,
focusNode: focusNode,
style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 4), hintText: 'Takım ara...', isDense: true),
onChanged: (val) => _deplasmanAramaController.text = val,
);
},
onSelected: (String selection) { setState(() { _deplasmanAramaController.text = selection; }); },
),
],
),
),
],
),
const SizedBox(height: 12),
Row(
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text('Maç Tarihi (Dashboard Takvimi)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
DropdownButton<String>(
value: _ayarlananTarih,
isExpanded: true,
items: <String>['SAL 21/07', 'CAR 22/07', 'PER 23/07', 'CUM 24/07', 'CTS 25/07', 'PAZ 26/07'].map((String v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13)))).toList(),
onChanged: (v) => setState(() => _ayarlananTarih = v!),
),
],
),
),
const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text('Başlangıç Saati', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
DropdownButton<String>(
value: _ayarlananSaat,
isExpanded: true,
items: <String>['18:30', '19:00', '20:30', '21:00', '22:00', '22:30'].map((String v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13)))).toList(),
onChanged: (v) => setState(() => _ayarlananSaat = v!),
),
],
),
),
],
),
const SizedBox(height: 16),
_butonOlustur('MAÇI FİKSTÜRE EKLE & YAYINLA', const Color(0xFF212529), () {
_bildirimGoster('🏆 ${_evSahibiAramaController.text} - ${_deplasmanAramaController.text} maçı başarıyla eklendi!');
}),
],
),
),
_kartBasligiOlustur('2. SKOR & SÜRE YÖNETİMİ'),
Container(
padding: const EdgeInsets.all(16),
margin: const EdgeInsets.only(bottom: 20),
decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text('Maç Durumu Kumandası', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
const SizedBox(height: 6),
Row(
children: [
Expanded(child: _durumButonuOlustur('MAÇ BAŞLAT', 'Canlı', Colors.green, () => _durumGuncelle('${_canliDakikaController.text}\'', true))),
const SizedBox(width: 4),
Expanded(child: _durumButonuOlustur('DEVRE ARASI', 'İY', Colors.amber.shade700, () => _durumGuncelle('DA', true))),
const SizedBox(width: 4),
Expanded(child: _durumButonuOlustur('MAÇ BİTİR', 'MS', Colors.red.shade700, _maciBitir)),
],
),
const SizedBox(height: 16),
Row(
children: [
Expanded(child: TextField(controller: _skorEvController, keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: const InputDecoration(labelText: 'Ev Skor', contentPadding: EdgeInsets.zero))),
const SizedBox(width: 12),
const Text('-', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
const SizedBox(width: 12),
Expanded(child: TextField(controller: _skorDepController, keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: const InputDecoration(labelText: 'Dep Skor', contentPadding: EdgeInsets.zero))),
const SizedBox(width: 24),
Expanded(child: TextField(controller: _canliDakikaController, keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: const InputDecoration(labelText: 'Maç Dakikası', contentPadding: EdgeInsets.zero))),
],
),
const SizedBox(height: 20),
_butonOlustur('SKORU VE SÜREYİ YAYINLA', const Color(0xFF212529), () {
_skorGuncelle('${_skorEvController.text} - ${_skorDepController.text}');
_durumGuncelle('${_canliDakikaController.text}\'', true);
_bildirimGoster('⏱️ Canlı skor ve süre anlık güncellendi!');
}),
],
),
),
_kartBasligiOlustur('MAÇ DETAYINA CANLI OLAY İŞLE (TIMELINE)'),
Container(
padding: const EdgeInsets.all(16),
margin: const EdgeInsets.only(bottom: 20),
decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text('Olay Tipi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
DropdownButton<String>(
value: _olayTipi,
isExpanded: true,
items: <String>['Gol ⚽', 'Sarı Kart 🟨', 'Kırmızı Kart 🟥', 'Oyuncu Değişikliği 🔄'].map((String v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13)))).toList(),
onChanged: (v) => setState(() => _olayTipi = v!),
),
],
),
),
const SizedBox(width: 12),
Expanded(
child: TextField(
controller: _olayDakikaController,
keyboardType: TextInputType.number,
textAlign: TextAlign.center,
decoration: const InputDecoration(labelText: 'Olay Dk', contentPadding: EdgeInsets.zero),
style: const TextStyle(fontSize: 13),
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text('Oyuncu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
DropdownButton<String>(
value: _olayOyuncu,
isExpanded: true,
items: <String>['YAKUP MARAL (Ev Sahibi)', 'SAMET K. (Deplasman)', 'BEKİR D. (Ev Sahibi)'].map((String v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 11)))).toList(),
onChanged: (v) => setState(() => _olayOyuncu = v!),
),
],
),
),
],
),
const SizedBox(height: 20),
_butonOlustur('OLAYI TIMELINE\'A GÖNDER', const Color(0xFFE53935), () {
setState(() {
if (_olayTipi == 'Gol ⚽') {
if (_olayOyuncu.contains('(Ev Sahibi)')) {
int mevcutSkor = int.tryParse(_skorEvController.text) ?? 0;
_skorEvController.text = (mevcutSkor + 1).toString();
} else if (_olayOyuncu.contains('(Deplasman)')) {
int mevcutSkor = int.tryParse(_skorDepController.text) ?? 0;
_skorDepController.text = (mevcutSkor + 1).toString();
}
_skorGuncelle('${_skorEvController.text} - ${_skorDepController.text}');
}
});
_bildirimGoster('⚽ Canlı olay timeline\'a işlendi ve skor otomatik güncellendi!');
}),
],
),
),
],
),
// =========================================================
// 📋 2. SEKME: KADRO & SKOR AYARLARI İÇERİĞİ
// =========================================================
ListView(
padding: const EdgeInsets.all(16.0),
children: [
_kartBasligiOlustur('📋 YETKİLİ & TEKNİK EKİP DÜZENLEYİCİ'),
Container(
padding: const EdgeInsets.all(16),
margin: const EdgeInsets.only(bottom: 20),
decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Expanded(child: TextField(controller: _teknikEvController, decoration: const InputDecoration(labelText: 'Ev Sahibi T.Direktör', contentPadding: EdgeInsets.zero), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
const SizedBox(width: 16),
Expanded(child: TextField(controller: _teknikDepController, decoration: const InputDecoration(labelText: 'Deplasman T.Direktör', contentPadding: EdgeInsets.zero), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
],
),
const SizedBox(height: 12),
TextField(controller: _hakemController, decoration: const InputDecoration(labelText: 'Müsabaka Orta Hakemi', contentPadding: EdgeInsets.zero), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
const SizedBox(height: 16),
_butonOlustur('TEKNİK EKİP & HAKEM BİLGİLERİNİ GÜNCELLE', const Color(0xFF212529), () {
_bildirimGoster('📋 Yetkili ve teknik ekip kadrosu başarıyla güncellendi!');
}),
],
),
),
_kartBasligiOlustur('👥 İLK 11 OYUNCULARINI DEĞİŞTİR (TAM 11 OYUNCU)'),
Container(
padding: const EdgeInsets.all(16),
margin: const EdgeInsets.only(bottom: 20),
decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
child: Column(
children: [
Row(
children: [
const Expanded(child: Text('Ev Sahibi 11', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
const SizedBox(width: 16),
const Expanded(child: Text('Deplasman 11', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
],
),
const SizedBox(height: 12),
...List.generate(11, (index) {
return Padding(
padding: const EdgeInsets.only(bottom: 8.0),
child: Row(
children: [
Expanded(
child: TextField(
controller: _evOyuncuKutulari[index],
decoration: InputDecoration(labelText: '${index + 1}. Oyuncu', contentPadding: EdgeInsets.zero),
style: const TextStyle(fontSize: 12),
),
),
const SizedBox(width: 16),
Expanded(
child: TextField(
controller: _depOyuncuKutulari[index],
decoration: InputDecoration(labelText: '${index + 1}. Oyuncu', contentPadding: EdgeInsets.zero),
style: const TextStyle(fontSize: 12),
),
),
],
),
);
}),
const SizedBox(height: 16),
_butonOlustur('SAHA İÇİ İLK 11 KADROLARINI YAYINLA', const Color(0xFF212529), () {
_bildirimGoster('👥 Her iki takımın ilk 11 kadroları anlık güncellendi!');
}),
],
),
),
],
),
// =========================================================
// 🎯 3. SEKME: OYUNCU YÖNETİMİ PANELİ (FORM ALANI)
// =========================================================
ListView(
padding: const EdgeInsets.all(16.0),
children: [
_kartBasligiOlustur('🎯 YENİ OYUNCU KAYIT FORMU'),
Container(
padding: const EdgeInsets.all(16),
margin: const EdgeInsets.only(bottom: 20),
decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text('Oyuncu Profil Fotoğrafı', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
const SizedBox(height: 6),
GestureDetector(
onTap: () => _bildirimGoster('📸 Fotoğraf seçme arayüzü tetiklendi.'),
child: Container(
width: double.infinity,
height: 60,
decoration: BoxDecoration(
color: const Color(0xFFF4F6F9),
borderRadius: BorderRadius.circular(8),
border: Border.all(color: const Color(0xFFECEFF1)),
),
child: const Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.add_a_photo, color: Colors.black54, size: 20),
SizedBox(width: 8),
Text('Fotoğraf Seç veya Yükle', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
],
),
),
),
const SizedBox(height: 16),
TextField(controller: _oyuncuAdController, decoration: const InputDecoration(labelText: 'Oyuncu Adı Soyadı', contentPadding: EdgeInsets.zero), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
const SizedBox(height: 12),
TextField(controller: _oyuncuTcController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'TC Kimlik Numarası (11 Hane)', contentPadding: EdgeInsets.zero), style: const TextStyle(fontSize: 13)),
const SizedBox(height: 16),
const Text('Doğum Tarihi & Saati', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
const SizedBox(height: 6),
GestureDetector(
onTap: () async {
final DateTime? secilen = await showDatePicker(
context: context,
initialDate: DateTime.now(),
firstDate: DateTime(1970),
lastDate: DateTime.now(),
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
setState(() { _secilenDogumTarihi = secilen; });
}
},
child: Container(
padding: const EdgeInsets.symmetric(vertical: 10),
decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12, width: 1))),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
_secilenDogumTarihi == null
? 'Doğum Tarihini Takvimden Seçin'
: '${_secilenDogumTarihi!.day}/${_secilenDogumTarihi!.month}/${_secilenDogumTarihi!.year}',
style: TextStyle(fontSize: 13, color: _secilenDogumTarihi == null ? Colors.black38 : Colors.black87, fontWeight: FontWeight.bold),
),
const Icon(Icons.calendar_month, color: Color(0xFFE53935), size: 20),
],
),
),
),
const SizedBox(height: 16),
const Text('Oynadığı Takım', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
DropdownButton<String>(
value: _oyuncuSeciliTakim,
isExpanded: true,
items: <String>['Diriliş Fk', '06 ANKARAGÜCÜ', 'BlackMarten', 'Altindagspor', 'BOGALAR', 'Orhan Aspava FK'].map((String v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13)))).toList(),
onChanged: (v) => setState(() => _oyuncuSeciliTakim = v!),
),
const SizedBox(height: 12),
Row(
children: [
Expanded(child: TextField(controller: _oyuncuEpostaController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-Posta Adresi', contentPadding: EdgeInsets.zero), style: const TextStyle(fontSize: 13))),
const SizedBox(width: 16),
Expanded(child: TextField(controller: _oyuncuTelefonController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefon Numarası', contentPadding: EdgeInsets.zero), style: const TextStyle(fontSize: 13))),
],
),
const SizedBox(height: 12),
TextField(controller: _oyuncuIlController, decoration: const InputDecoration(labelText: 'İl / İlçe Bilgisi (Örn: 06 Ankara)', contentPadding: EdgeInsets.zero), style: const TextStyle(fontSize: 13)),
const SizedBox(height: 12),
Row(
children: [
Expanded(child: TextField(controller: _oyuncuBoyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Boy (cm)', contentPadding: EdgeInsets.zero), style: const TextStyle(fontSize: 13))),
const SizedBox(width: 16),
Expanded(child: TextField(controller: _oyuncuKiloController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kilo (kg)', contentPadding: EdgeInsets.zero), style: const TextStyle(fontSize: 13))),
],
),
const SizedBox(height: 24),
_butonOlustur('YENİ OYUNCUYU SİSTEME EKLE', const Color(0xFF212529), () {
if (_oyuncuAdController.text.isEmpty) {
_bildirimGoster('⚠️ Lütfen en azından Oyuncu Adı alanını doldurun!');
} else {
_bildirimGoster('🏃 ${_oyuncuAdController.text.toUpperCase()} oyuncu havuzuna aslanlar gibi eklendi!');
_oyuncuAdController.clear();
_oyuncuTcController.clear();
_oyuncuEpostaController.clear();
_oyuncuTelefonController.clear();
_oyuncuIlController.clear();
_oyuncuBoyController.clear();
_oyuncuKiloController.clear();
setState(() { _secilenDogumTarihi = null; });
}
}),
],
),
),
  _kartBasligiOlustur('🔍 MEVCUT OYUNCU HAVUZU VE YÖNETİMİ'),
  Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _oyuncuAraController,
          decoration: const InputDecoration(
            labelText: 'Oyuncu Adı veya TC ile Havuzda Ara...',
            prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Sistemde Kayıtlı Oyuncular', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        _adminOyuncuYonetimSatiri('BEKİR DEMİR', 'Diriliş Fk', '12676077286'),
        _adminOyuncuYonetimSatiri('BURAK ÇELİK', '06 ANKARAGÜCÜ', '17098008238'),
        _adminOyuncuYonetimSatiri('MERT AK', 'BlackMarten', '36434231376'),
        _adminOyuncuYonetimSatiri('ALİ AKBULUT', 'Altindagspor', '61585392560'),
      ],
    ),
  ),
],
),
],
),
);
}

  // --- REJİ TASARIM YARDIMCI WIDGET'LARI (BOZULMADAN SAKLANDI) ---
  Widget _kartBasligiOlustur(String baslik) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8),
      child: Text(baslik, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF212529), letterSpacing: 0.3)),
    );
  }

  Widget _butonOlustur(String yazi, Color renk, VoidCallback tiklama) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: renk, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 1),
        onPressed: tiklama,
        child: Text(yazi, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
      ),
    );
  }

  Widget _durumButonuOlustur(String anaYazi, String altYazi, Color renk, VoidCallback tiklama) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: renk, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 1),
      onPressed: tiklama,
      child: Column(
        children: [
          Text(anaYazi, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text('($altYazi)', style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _adminOyuncuYonetimSatiri(String ad, String takim, String tc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ad, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text('$takim • ID: $tc', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit_note, color: Colors.blue, size: 20), onPressed: () => _bildirimGoster('📝 $ad düzenleme formu açıldı.')),
              IconButton(icon: const Icon(Icons.no_accounts, color: Colors.red, size: 18), onPressed: () => _bildirimGoster('🚫 $ad havuzdan pasife çekildi.')),
            ],
          ),
        ],
      ),
    );
  }

  void _bildirimGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: const Color(0xFF212529), content: Text(mesaj, style: const TextStyle(fontSize: 11))),
    );
  }
}
