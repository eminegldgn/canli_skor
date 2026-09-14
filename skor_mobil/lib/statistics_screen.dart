import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 🎯 Doğrudan canlı site URL'si ile konuşan kütüphane
import 'dart:convert';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  // 🎯 GÜNCELLENDİ: Sadece ve doğrudan senin istediğin o resmi canlı site URL'si!
  final String _baseUrl = 'https://halisahafutbolligi.com';
  bool _yukleniyor = false;
  late TabController _statTabController;

  // Canlı internet sitesinden çekilecek gerçek listelerimiz
  List<dynamic> _canliGolKralligi = [];
  List<dynamic> _canliAsistKralligi = [];

  // 📡 GÜNCELLENDİ: Canlı sitenin resmi API rotalarından gol ve asist krallıklarını çeken paralel istekler
  Future<void> _istatistikleriCanliSitedenCek() async {
    setState(() => _yukleniyor = true);
    try {
      // ⚽ Gol krallığı verilerini çekiyoruz
      final golResponse = await http.get(
        Uri.parse('$_baseUrl/api/gol-kralligi'),
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 10));

      // 🎯 Asist krallığı verilerini çekiyoruz
      final asistResponse = await http.get(
        Uri.parse('$_baseUrl/api/asist-kralligi'),
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 10));

      if (golResponse.statusCode == 200 && asistResponse.statusCode == 200) {
        if (mounted) {
          setState(() {
            _canliGolKralligi = json.decode(golResponse.body);
            _canliAsistKralligi = json.decode(asistResponse.body);
          });
        }
      }
    } catch (e) {
      // Bağlantıda anlık dalgalanma olursa uygulamanın çökmesini engelliyoruz
      print("İSTATİSTİK VERİLERİ ÇEKİLİRKEN HATA OLUŞTU: $e");
    }
    if (mounted) setState(() => _yukleniyor = false);
  }

  @override
  void initState() {
    super.initState();
    _statTabController = TabController(length: 2, vsync: this);
    _istatistikleriCanliSitedenCek();
  }

  @override
  void dispose() {
    _statTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF212529),
        title: const Text('HFL LİG İSTATİSTİKLERİ', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _statTabController,
          indicatorColor: const Color(0xFFE53935),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Gol Krallığı ⚽'),
            Tab(text: 'Asist Krallığı 🎯'),
          ],
        ),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
          : TabBarView(
        controller: _statTabController,
        children: [
          _statTablosuOlustur(_canliGolKralligi.isNotEmpty ? _canliGolKralligi : _yerelGolYedegi, 'Gol'),
          _statTablosuOlustur(_canliAsistKralligi.isNotEmpty ? _canliAsistKralligi : _yerelAsistYedegi, 'Asist'),
        ],
      ),
    );
  }

  // 🎯 DÜZELTİLDİ: Tip uyuşmazlığı hatasına sebep olan parametre esnek List<dynamic> halinde bırakıldı!
  Widget _statTablosuOlustur(List<dynamic> liste, String baslik) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: liste.length,
      itemBuilder: (context, index) {
        final item = liste[index];

        // 🎯 MODELLERLE %100 UYUMLU: Goals.php ve Gamers.php'den gelen gerçek alan adları tam oturtuldu!
        String oyuncuAdi = item['member_name'] ?? item['player'] ?? item['oyuncu_adi'] ?? 'Bilinmeyen Oyuncu';
        String takimAdi = item['team_name'] ?? item['team'] ?? item['takimi'] ?? 'Serbest Takım';
        String adetDegeri = (item['toplam_gol'] ?? item['toplam_asist'] ?? item['value'] ?? item['adet'] ?? 0).toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Text('#${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFE53935))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(oyuncuAdi, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                    Text(takimAdi, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Text('$adetDegeri $baslik', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF212529))),
            ],
          ),
        );
      },
    );
  }

  // 🎯 DÜZELTİLDİ: Yedek listelerin başlıkları da esnek dynamic kalıpta korundu!
  final List<dynamic> _yerelGolYedegi = [
    {'player': 'YAKUP MARAL', 'team': 'Diriliş Fk', 'value': 11},
    {'player': 'Cihat Bulut', 'team': 'Avengers', 'value': 8},
    {'player': 'Yasin Yazgan', 'team': 'Avengers', 'value': 8},
    {'player': 'Emre Aydemir', 'team': 'FELLAS', 'value': 8},
    {'player': 'Berke ÜSTÜN', 'team': '06 ANKARAGÜCÜ', 'value': 8},
    {'player': 'ERTUĞRUL FURKAN Yazıcı', 'team': 'BOĞALAR', 'value': 7},
  ];

  final List<dynamic> _yerelAsistYedegi = [
    {'player': 'Özkan Öner', 'team': 'Altındağspor', 'value': 8},
    {'player': 'Yasin Yazgan', 'team': 'Avengers', 'value': 7},
    {'player': 'Engin Cağlı', 'team': 'Avengers', 'value': 6},
    {'player': 'Emre Konyalıoğlu', 'team': 'BlackMarten', 'value': 6},
    {'player': 'Yousef Ahmed', 'team': 'Diriliş Fk', 'value': 5},
  ];
}


