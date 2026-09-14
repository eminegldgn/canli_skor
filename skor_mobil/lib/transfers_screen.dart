import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  final String _baseUrl = 'https://www.halisahafutbolligi.com';

  bool _yukleniyor = false;

  // Mock Transfer Talepleri Listesi (Arayüzün dolması için)
  final List<Map<String, dynamic>> _transferTalepleri = [
    {
      'id': 101,
      'player_name': 'YAKUP MARAL',
      'old_team': 'Altınorda FK',
      'new_team': 'Diriliş Fk',
      'date': '28/07/2026'
    },
    {
      'id': 102,
      'player_name': 'SAMET K.',
      'old_team': 'Gençlik Gücü',
      'new_team': '06 ANKARAGÜCÜ',
      'date': '27/07/2026'
    }
  ];

  // 📡 GET: Transferleri Listele (Route: transfers)
  Future<void> _tumTransferleriGetir() async {
    setState(() => _yukleniyor = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/transfers'));
    } catch (e) {}
    setState(() => _yukleniyor = false);
  }

  // 📡 POST: Transfer Talebi Gönder (Route: addTransferRequests)
  Future<void> _transferTalebiEkle(String oyuncuId, String yeniTakimId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/addTransferRequests'),
        body: {'gamer_id': oyuncuId, 'team_id': yeniTakimId},
      );
      _bildirimGoster('🚀 Transfer talebi sisteme iletildi!');
    } catch (e) {}
  }

  // 📡 GET: Transfer Onayla (Route: transfer.approve)
  Future<void> _transferOnayla(int id) async {
    try {
      await http.get(Uri.parse('$_baseUrl/transfer_approved/$id'));
      _bildirimGoster('✅ Transfer resmi olarak onaylandı!');
    } catch (e) {}
  }

  // 📡 GET: Transfer Reddet (Route: transfer.reject)
  Future<void> _transferReddet(int id) async {
    try {
      await http.get(Uri.parse('$_baseUrl/transfer_reject/$id'));
      _bildirimGoster('❌ Transfer talebi reddedildi.');
    } catch (e) {}
  }


  @override
  void initState() {
    super.initState();
    _tumTransferleriGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF212529),
        title: const Text('HFL TRANSFER MERKEZİ', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transferTalepleri.length,
        itemBuilder: (context, index) {
          final transfer = _transferTalepleri[index];
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
                    Text(transfer['player_name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(transfer['date'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(transfer['old_team'], style: TextStyle(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.w500)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                    ),
                    Text(transfer['new_team'], style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500)),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFECEFF1), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                      icon: const Icon(Icons.close, size: 14, color: Colors.black54),
                      label: const Text('Reddet', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      onPressed: () => _transferReddet(transfer['id']),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF212529), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                      icon: const Icon(Icons.check, size: 14, color: Colors.white),
                      label: const Text('Onayla', style: TextStyle(fontSize: 11, color: Colors.white)),
                      onPressed: () => _transferOnayla(transfer['id']),
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

  void _bildirimGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: const Color(0xFF212529), content: Text(mesaj, style: const TextStyle(fontSize: 11))),
    );
  }
}
