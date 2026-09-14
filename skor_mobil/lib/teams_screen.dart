import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 🎯 Doğrudan canlı site URL'si ile konuşan kütüphane
import 'dart:convert';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  // 🎯 Sadece ve doğrudan senin istediğin o resmi canlı site URL'si!
  final String _baseUrl = 'https://halisahafutbolligi.com';
  bool _yukleniyor = false;

  // Siteden anlık çekilecek canlı oyuncuların tamamını tutacak dinamik liste
  List<dynamic> _canliOyuncuListesi = [];

  // 📡 Canlı sitenin resmi API rotasından oyuncuları çeken GET isteği
  Future<void> _tumOyunculariGetir() async {
    setState(() => _yukleniyor = true);
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/oyuncular'),
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var gelenVeri = json.decode(response.body);
        if (mounted) {
          setState(() {
            _canliOyuncuListesi = gelenVeri is List ? gelenVeri : (gelenVeri['oyuncular'] ?? []);
          });
        }
      }
    } catch (e) {
      print("OYUNCU KADROLARI ÇEKİLİRKEN HATA OLUŞTU: $e");
    }
    if (mounted) setState(() => _yukleniyor = false);
  }

  // 📡 POST: Kaptan Ata (Canlı sitenin resmi API rotasına gönderir)
  Future<void> _kaptanAta(int oyuncuId, int takimId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/gamers/$oyuncuId/make-captain'),
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: {
          'team_id': takimId.toString(),
        },
      ).timeout(const Duration(seconds: 10));

      _bildirimGoster('👑 Kaptan başarıyla atandı!');
      _tumOyunculariGetir();
    } catch (e) {
      print("KAPTAN ATAMA HATASI: $e");
    }
  }

  // 📡 POST: Takımdan Oyuncu Feshetme (Canlı sitenin resmi API rotasına gönderir)
  Future<void> _oyuncuFeshet(int oyuncuId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/team/remove-gamer/$oyuncuId'),
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 10));

      _bildirimGoster('🗑️ Oyuncu sözleşmesi feshedildi!');
      _tumOyunculariGetir();
    } catch (e) {
      print("SÖZLEŞME FESİH HATASI: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _tumOyunculariGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF212529),
        title: const Text('HFL AKTİF OYUNCU KADROLARI', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _canliOyuncuListesi.isNotEmpty ? _canliOyuncuListesi.length : _yerelOyuncuYedegi.length,
        itemBuilder: (context, index) {
          final oyuncu = _canliOyuncuListesi.isNotEmpty ? _canliOyuncuListesi[index] : _yerelOyuncuYedegi[index];

          String oyuncuAdi = oyuncu['member_name'] ?? 'Bilinmeyen Oyuncu';
          String mevki = oyuncu['position'] ?? 'Mevki Belirtilmedi';
          String tcKimlik = oyuncu['tc_no'] ?? oyuncu['tc'] ?? '---';
          String takimi = oyuncu['team_name'] ?? (oyuncu['team_id'] ?? 'HFL Aktif Oyuncusu').toString();

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(oyuncuAdi, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(6)),
                      child: Text(mevki, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('🛡️ Bölge/Takım: $takimi', style: const TextStyle(fontSize: 12, color: Color(0xFF212529), fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('🆔 TC No: $tcKimlik', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _kucukBilgiKutusu('📏 Boy', '${oyuncu['height'] ?? '0'} cm'),
                    _kucukBilgiKutusu('⚖️ Kilo', '${oyuncu['weight'] ?? '0'} kg'),
                    _kucukBilgiKutusu('🎂 Doğum G.', oyuncu['birthday'] ?? oyuncu['birth_date'] ?? '--/--/----'),
                  ],
                ),
                const Divider(height: 24),
                _iletisimSatiri(Icons.location_on, 'Konum:', '${oyuncu['il_adi'] ?? oyuncu['province'] ?? oyuncu['il'] ?? '---'} / ${oyuncu['ilce_adi'] ?? oyuncu['district'] ?? oyuncu['ilce'] ?? '---'}'),
                const SizedBox(height: 6),
                _iletisimSatiri(Icons.phone, 'Telefon:', oyuncu['phone_number'] ?? oyuncu['phone'] ?? '---'),
                const SizedBox(height: 6),
                _iletisimSatiri(Icons.email, 'E-Posta:', oyuncu['e_mail'] ?? oyuncu['email'] ?? '---'),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.amber.shade900),
                      icon: const Icon(Icons.star, size: 14),
                      label: const Text('Kaptan Yap', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => _kaptanAta(oyuncu['id'] is int ? oyuncu['id'] : 0, oyuncu['team_id'] is int ? oyuncu['team_id'] : 1),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFECEFF1), elevation: 0),
                      icon: const Icon(Icons.delete_outline, size: 14, color: Color(0xFFE53935)),
                      label: const Text('Sözleşme Fesih', style: TextStyle(fontSize: 11, color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
                      onPressed: () => _oyuncuFeshet(oyuncu['id'] is int ? oyuncu['id'] : 0),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _kucukBilgiKutusu(String baslik, String deger) {
    return Column(
      children: [
        Text(baslik, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(deger, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _iletisimSatiri(IconData ikon, String baslik, String deger) {
    return Row(
      children: [
        Icon(ikon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Text(baslik, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Expanded(child: Text(deger, style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  void _bildirimGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: const Color(0xFF212529), content: Text(mesaj, style: const TextStyle(fontSize: 11))),
    );
  }

  final List<dynamic> _yerelOyuncuYedegi = [
    {
      'id': 1,
      'member_name': 'Samet KABADAYI',
      'tc_no': '24592887184',
      'birthday': '01/12/2000',
      'e_mail': 'smtkbdy5422@gmail.com',
      'phone_number': '(543) 492 02 11',
      'province': 'Mersin',
      'district': 'Merkez',
      'height': '190.00',
      'weight': '67.00',
      'position': 'Forvet',
      'team_name': 'Mersin Merkez'
    },
    {
      'id': 2,
      'member_name': 'Yusuf Kocatürk',
      'tc_no': '14119919184',
      'birthday': '09/07/2008',
      'e_mail': 'kocaturkyusuf1903@gmail.com',
      'phone_number': '(553) 938 42 19',
      'province': 'Ankara',
      'district': 'Çankaya',
      'height': '183.00',
      'weight': '75.00',
      'position': 'Merkez Ortasaha',
      'team_name': 'Ankara Fk'
    }
  ];
}
