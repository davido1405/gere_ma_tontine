import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/beneficiare.dart';
import 'package:gerematontine/models/session.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

import '../../constants/colors.dart';
import '../../constants/server.dart';

class tourTontine extends StatefulWidget {
  final Session listsession;
  const tourTontine({super.key, required this.listsession});

  @override
  State<tourTontine> createState() => _tourTontineState();
}

class _tourTontineState extends State<tourTontine> {

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    verifierTour();
    listeBeneficiare();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      verifierTour();
      listeBeneficiare();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<Beneficiare> _listOrdre = [];
  late String nomBeneficiare = "N/A";
  late String prenomsBeneficiare = "N/A";
  late int positionBeneficiare = 0;
  late String dateBeneficiare = "N/A";
  late int toursCompletes = 0;
  late int totalTours = 0;
  late int tourActuel = 0; // ✅ NOUVEAU
  String moisTourActuel = "En attente";
  String moisMonTour = "En attente";

  Future<void> verifierTour() async {
    String? jwt = await widget.listsession.getSecureJwt();
    final url = Uri.parse("${adress}?ressource=participants&action=verifierTour");
    final response = await post(
      url,
      headers: {
        "content-Type": "application/json",
        "Authorization": "Bearer $jwt"
      },
      body: jsonEncode({"code_tontine": widget.listsession.code_tontine}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> donnee = jsonDecode(response.body);
      if (donnee['success'] == true) {
        var tour = donnee['data'];
        if (tour != null && mounted) {
          setState(() {
            nomBeneficiare = tour['nom_participant'];
            prenomsBeneficiare = tour['prenoms_participant'];
            positionBeneficiare = tour['ordre'];
            dateBeneficiare = tour['date_tour'] ?? "N/A";
          });
        }
      }
    }
  }

  Future<void> listeBeneficiare() async {
    if (!mounted) return;
    String? jwt = await widget.listsession.getSecureJwt();
    final url = Uri.parse("${adress}?ressource=tontines&action=ordre_paiement");
    final response = await post(
      url,
      headers: {
        'content-Type': 'application/json',
        "Authorization": "Bearer $jwt"
      },
      body: jsonEncode({"code_tontine": widget.listsession.code_tontine}),
    );

    if (!mounted) return;
    if (response.statusCode == 200) {
      final Map<String, dynamic> donnee = jsonDecode(response.body);
      bool succes = donnee['success'];

      if (succes) {
        Map<String, dynamic> data = donnee['data'];
        List<dynamic> beneficiaires = data['beneficiaires'] ?? [];
        Map<String, dynamic> stats = data['statistiques'] ?? {};

        if (!mounted) return;
        setState(() {
          _listOrdre = beneficiaires.map((b) => Beneficiare.fromJson(b)).toList();

          // ✅ Récupérer les statistiques
          toursCompletes = stats['tours_completes'] ?? 0;
          totalTours = stats['total_tours'] ?? 0;
          tourActuel = stats['tour_actuel'] ?? 0; // ✅ NOUVEAU

          // ✅ Calculer les mois basé sur le champ 'etat' du backend
          if (_listOrdre.isNotEmpty) {
            // Tour actuel (etat = 'en_cours')
            var tourEnCours = _listOrdre.firstWhere(
                  (b) => b.etatBeneficiare == 'en_cours',
              orElse: () => _listOrdre.first,
            );
            moisTourActuel = _getMoisFromDate(tourEnCours.dateTour);

            // Mon tour
            var monTour = _listOrdre.firstWhere(
                  (b) => b.codeBeneficiare == widget.listsession.code_participant,
              orElse: () => _listOrdre.first,
            );
            moisMonTour = _getMoisFromDate(monTour.dateTour);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Planning des tours",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              widget.listsession.code_tontine ?? "Tontine",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: ()async{
            await verifierTour();
            await listeBeneficiare();
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // HEADER CARD
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Couleur.primaryBlue, Couleur.secondaryGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Couleur.primaryBlue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHeaderItem(
                          "Tours\ncomplétés",
                          "$toursCompletes/$totalTours",
                        ),
                        Container(
                          width: 1,
                          height: 40.h,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        _buildHeaderItem(
                          "Tour actuel",
                          moisTourActuel,
                        ),
                        Container(
                          width: 1,
                          height: 40.h,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        _buildHeaderItem(
                          "Mon tour",
                          moisMonTour,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // LÉGENDE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem("Complété", Couleur.secondaryGreen),
                      _buildLegendItem("En cours", Couleur.primaryBlue),
                      _buildLegendItem("À venir", Colors.grey[300]!),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // LISTE DES BÉNÉFICIAIRES
                  _listOrdre.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          "assets/animations/No-Data.json",
                          width: 150.w,
                          height: 150.h,
                        ),
                        SizedBox(height: 15.h),
                        Text(
                          "Les tours seront générés automatiquement",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _listOrdre.length,
                    itemBuilder: (context, index) {
                      final Beneficiare beneficiaire = _listOrdre[index];

                      // ✅ NOUVELLE LOGIQUE basée sur le champ 'etat' du backend
                      bool estEnCours = beneficiaire.etatBeneficiare == 'en_cours';
                      bool estComplete = beneficiaire.etatBeneficiare == 'complete';
                      bool estAVenir = beneficiaire.etatBeneficiare == 'a_venir';
                      bool estMoi = widget.listsession.code_participant == beneficiaire.codeBeneficiare;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: estEnCours
                              ? Border.all(color: Couleur.primaryBlue, width: 2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Row(
                            children: [
                              // ICÔNE STATUT
                              Container(
                                width: 50.w,
                                height: 50.w,
                                decoration: BoxDecoration(
                                  color: estComplete
                                      ? Couleur.secondaryGreen
                                      : estEnCours
                                      ? Couleur.primaryBlue
                                      : Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  estComplete
                                      ? Icons.check
                                      : estEnCours
                                      ? Icons.calendar_today
                                      : Icons.schedule,
                                  color: estComplete || estEnCours
                                      ? Colors.white
                                      : Colors.grey[400],
                                  size: 24.sp,
                                ),
                              ),

                              SizedBox(width: 16.w),

                              // CONTENU
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          estMoi ? "👤" : "👥",
                                          style: TextStyle(fontSize: 18.sp),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            estMoi
                                                ? "Vous"
                                                : "${beneficiaire.prenomsBeneficiare} ${beneficiaire.nomBeneficiare}",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      _getMoisFromDate(beneficiaire.dateTour),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Position #${beneficiaire.positionBeneficiare}",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        Text(
                                          "${beneficiaire.montant ?? 0} FCFA",
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Couleur.primaryBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (estComplete || estEnCours) ...[
                                      SizedBox(height: 8.h),
                                      Row(
                                        children: [
                                          Icon(
                                            estComplete
                                                ? Icons.check_circle
                                                : Icons.access_time,
                                            color: estComplete
                                                ? Couleur.secondaryGreen
                                                : Couleur.primaryBlue,
                                            size: 14.sp,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            estComplete
                                                ? "Paiement effectué"
                                                : "En cours - Fin le ${beneficiaire.dateTour.split(' ')[0]}",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: estComplete
                                                  ? Couleur.secondaryGreen
                                                  : Couleur.primaryBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.white.withOpacity(0.9),
            height: 1.2,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  String _getMoisFromDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date.split(' ')[0]);
      List<String> mois = [
        'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
      ];
      return "${mois[dateTime.month - 1]} ${dateTime.year}";
    } catch (e) {
      return date.split(' ')[0];
    }
  }
}