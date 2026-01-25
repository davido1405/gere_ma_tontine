import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/session.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:http/http.dart' as http;

import '../../constants/colors.dart';
import '../../constants/server.dart';

class VueGlobale extends StatefulWidget {
  final Session listsession;
  const VueGlobale({super.key, required this.listsession});

  @override
  State<VueGlobale> createState() => _VueGlobaleState();
}

class _VueGlobaleState extends State<VueGlobale> {

  Map<DateTime, int> datasets = {};
  bool isLoading = true;
  List<Map<String, dynamic>> transactionsParDate = [];

  @override
  void initState() {
    super.initState();
    chargerTransactions();
  }

  Future<void> chargerTransactions() async {
    setState(() {
      isLoading = true;
    });

    String? jwt = await widget.listsession.getSecureJwt();
    final url = Uri.parse("${adress}?ressource=participants&action=vue_globale");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({
          'code_participant': widget.listsession.code_participant,
          'code_tontine': widget.listsession.code_tontine
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);

        print("✅ Réponse backend: ${result}");

        if (result['success'] == true) {
          Map<String, dynamic> data = result['data'];
          List<dynamic> transactions = data['transactions'] ?? [];

          Map<DateTime, int> tempDatasets = {};

          for (var item in transactions) {
            String dateStr = item['date'];
            DateTime date = DateTime.parse(dateStr);

            // ✅ CALCULER LE SCORE BASÉ SUR LES TYPES DE TRANSACTIONS
            int score = _calculerScore(item['transactions']);

            DateTime normalizedDate = DateTime(date.year, date.month, date.day);
            tempDatasets[normalizedDate] = score;
          }

          if (mounted) {
            setState(() {
              datasets = tempDatasets;
              transactionsParDate = transactions.cast<Map<String, dynamic>>();
              isLoading = false;
            });
          }

          print("✅ Datasets: $datasets");
        }
      }
    } catch (e, stackTrace) {
      print("❌ Erreur: $e");
      print("❌ StackTrace: $stackTrace");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ✅ FONCTION POUR CALCULER LE SCORE
  int _calculerScore(List<dynamic> transactions) {
    int score = 0;

    for (var t in transactions) {
      String type = t['type_transaction'];

      switch (type) {
        case 'cotisation_manquee':
          score = 1;  // Rouge : 1 point
          break;
        case 'cotisation_rattrapee':
          score = 3;  // Orange : 3 points
          break;
        case 'cotisation_payee':
          score = 6;  // Bleu : 6 points
          break;
        case 'distribution':
          score = 9;  // Vert : 9 points
          break;
      }
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Calendrier des transactions"),
            Text("Calendrier retraçant toutes vos transactions",style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600]
            ),)
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: chargerTransactions,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : datasets.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Center(
              child: Text(
                "Aucune transaction",
                style: TextStyle(fontSize: 18.sp, color: Colors.grey),
              ),
            ),
          ],
        ),
      ) : SingleChildScrollView(
        child: Column(
          children: [
            // ✅ LÉGENDE COHÉRENTE
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Types de transactions",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildLegendItem("Cotisation manquée", Colors.red, Icons.cancel),
                    SizedBox(height: 8.h),
                    _buildLegendItem("Cotisation rattrapée", Colors.orange, Icons.refresh),
                    SizedBox(height: 8.h),
                    _buildLegendItem("Cotisation payée", Colors.blueAccent, Icons.check_circle),
                    SizedBox(height: 8.h),
                    _buildLegendItem("Tour distribué", Colors.green, Icons.emoji_events),
                  ],
                ),
              ),
            ),
            // HEAT MAP
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0.w),
              child: HeatMapCalendar(
                defaultColor: Colors.grey[400],
                flexible: true,
                colorMode: ColorMode.color,
                datasets: datasets,
                colorsets: const {
                  1: Colors.red,        // Manquée
                  3: Colors.orange,     // Rattrapée
                  6: Colors.blueAccent, // Payée
                  9: Colors.green,      // Tour
                },
                textColor: Colors.white,
                onClick: (value) {
                  _showTransactionsForDate(value);
                },
              ),
            ),

            SizedBox(height: 20.h),

            // STATISTIQUES
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "Jours actifs",
                      "${datasets.length}",
                      Icons.calendar_today,
                      Couleur.primaryBlue,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      "Total",
                      "${datasets.values.fold(0, (sum, value) => sum + value)}",
                      Icons.show_chart,
                      Couleur.secondaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ LÉGENDE AMÉLIORÉE AVEC ICÔNE
  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionsForDate(DateTime date) {
    String dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    var transactionsJour = transactionsParDate.firstWhere(
          (t) => t['date'] == dateStr,
      orElse: () => {'transactions': []},
    );

    List<dynamic> transactions = transactionsJour['transactions'] ?? [];

    // ✅ Si aucune transaction, afficher une AlertDialog
    if (transactions.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Transactions du $dateStr",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "Aucune transaction ce jour",
              style: TextStyle(fontSize: 14.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Fermer"),
              ),
            ],
          );
        },
      );
      return; // ✅ Sortir de la fonction après avoir affiché le dialog
    }

    // ✅ Si des transactions existent, afficher le BottomSheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.w),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              // ✅ En-tête avec ligne de poignée
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // ✅ Titre
              Text(
                "Transactions du $dateStr",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 16.h),

              // ✅ Liste des transactions
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    var t = transactions[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8.h),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: _getColorForType(t['type_transaction']).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconForType(t['type_transaction']),
                            color: _getColorForType(t['type_transaction']),
                            size: 24.sp,
                          ),
                        ),
                        title: Text(
                          t['statut'] ?? 'N/A',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            t['code_cotisation'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        trailing: Text(
                          "${t['montant_transaction'] ?? 0} FCFA",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: _getColorForType(t['type_transaction']),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'cotisation_payee':
        return Icons.check_circle;
      case 'cotisation_manquee':
        return Icons.cancel;
      case 'cotisation_rattrapee':
        return Icons.refresh;
      case 'distribution':
        return Icons.emoji_events;
      default:
        return Icons.info;
    }
  }

  // ✅ COULEUR COHÉRENTE AVEC LE HEAT MAP
  Color _getColorForType(String type) {
    switch (type) {
      case 'cotisation_manquee':
        return Colors.red;
      case 'cotisation_rattrapee':
        return Colors.orange;
      case 'cotisation_payee':
        return Colors.blueAccent;
      case 'distribution':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}