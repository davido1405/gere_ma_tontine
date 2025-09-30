import 'dart:convert';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gerematontine/models/session.dart';
import 'package:gerematontine/screens/dashboard/ecran_dashboard.dart';
import 'package:gerematontine/screens/tontine/creer_tontine.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../constants/colors.dart';
import '../../constants/server.dart';

class participer extends StatefulWidget {
  final Session listsession;
  const participer({super.key, required this.listsession});

  @override
  State<participer> createState() => _participerState();
}

class _participerState extends State<participer> {

  @override
  void initState() {
    super.initState();
  }

  TextEditingController code = TextEditingController();
  bool _cacher = false; // CORRECTION 1: Ne plus masquer par défaut
  String? scannedCode;
  bool _isLoading = false; // AJOUT 1: État de chargement
  bool _scannerActive = true; // AJOUT 2: Contrôle du scanner
  MobileScannerController scannerController = MobileScannerController(); // AJOUT 3: Contrôleur scanner

  @override
  void dispose() {
    scannerController.dispose(); // AJOUT 4: Libération des ressources
    code.dispose();
    super.dispose();
  }

  // AJOUT 5: Validation du code tontine
  bool _isValidTontineCode(String code) {
    // Ajustez selon le format de vos codes tontine
    return code.isNotEmpty && code.length >= 6;
  }

  Future<void> participer() async {
    if (!_isValidTontineCode(code.text)) {
      _showErrorDialog("Code tontine invalide", "Veuillez vérifier le format du code");
      return;
    }

    // AJOUT 6: Gestion du loading state
    setState(() {
      _isLoading = true;
    });

    try {
      String? jwt = await widget.listsession.getSecureJwt();
      final url = Uri.parse("${adress}?ressource=participations&action=participer");
      final response = await http.post(
          url,
          headers: {
            "Authorization": "Bearer $jwt",
            "content-Type": "application/json",
          },
          body: jsonEncode({
            "code_participant": widget.listsession.code_participant,
            "code_tontine": code.text
          }));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        bool success = data['success'];
        if (success) {
            setState(() {
              widget.listsession.setCodeTontine(code.text);
            });
            Future.delayed(Duration(milliseconds: 300),(){
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => dashboard(listsession: widget.listsession)),
                      (route) => false);
            });
        } else {
          _showErrorDialog("Erreur", "Une erreur s'est produite veuillez réesayer plus tard ou contacter le service technique.");
        }
      } else {
        _showErrorDialog("Erreur serveur", "Une erreur s'est produite côté serveur. Veuillez réessayer plus tard");
      }
    } catch (e) {
      _showErrorDialog("Erreur", "Une erreur inattendue s'est produite");
    } finally {
      // AJOUT 7: Toujours arrêter le loading
      setState(() {
        _isLoading = false;
      });
    }
  }

  // AJOUT 8: Méthode factorisant l'affichage des erreurs
  void _showErrorDialog(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(backgroundColor: Couleur.secondaryGreen),
                  label: Text("Compris", style: TextStyle(color: Colors.white)),
                  icon: Icon(Icons.verified, color: Colors.white))
            ],
          );
        });
  }

  // AJOUT 9: Style factorisant pour les boutons
  ButtonStyle get _buttonStyle => TextButton.styleFrom(
    backgroundColor: Couleur.primaryBlue,
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text("Participer", style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1)),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 30.h),
          Center(
            child: Text("Scanner le QR Code de la tontine", style: TextStyle(fontSize: 14.sp)),
          ),
          SizedBox(height: 50.h),
          Center(
              child: SizedBox(
                width: 300.w,
                height: 300.h,
                child: Center(
                    child: Container(
                      color: Colors.grey,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r), // CORRECTION 2: Méthode correcte
                        child: MobileScanner(
                          controller: scannerController, // AJOUT 10: Utilisation du contrôleur
                          onDetect: (capture) async {
                            // CORRECTION 3: Vérifier si le scanner est actif
                            if (!_scannerActive || _isLoading) return;

                            final List<Barcode> barcodes = capture.barcodes;
                            bool foundValidCode = false; // AJOUT 11: Flag pour éviter multiples SnackBar

                            for (final barcode in barcodes) {
                              final String? qr = barcode.rawValue;
                              if (qr != null && qr.startsWith("tontine_plus/")) {
                                final extractedCode = qr.split('/')[1];

                                // CORRECTION 4: Validation du code extrait
                                if (_isValidTontineCode(extractedCode)) {
                                  setState(() {
                                    code.text = extractedCode;
                                    _scannerActive = false; // AJOUT 12: Désactiver le scanner
                                    _isLoading=true;
                                  });
                                  await participer();
                                  foundValidCode = true;
                                  break; // CORRECTION 5: Ajouter le break manquant
                                }
                              }
                            }

                            // CORRECTION 6: Un seul SnackBar par tentative de scan
                            if (!foundValidCode && barcodes.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Container(
                                      color: Colors.blue,
                                      padding: EdgeInsets.all(8.w),
                                      height: 80.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.report_outlined, color: Colors.red, size: 40.r),
                                          SizedBox(width: 20.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Echec"),
                                                Spacer(),
                                                Text("Veuillez scanner un QRCode Djarra Finances valide")
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.transparent,
                                    elevation: 3,
                                    duration: Duration(seconds: 2), // AJOUT 13: Durée limitée
                                  ));
                            }
                          },
                        ),
                      ),
                    )),
              )),
          SizedBox(height: 30.h),
          Center(
              child: Column(
                children: [
                  Text("Ou vous avez un code de tontine ?", style: TextStyle(fontSize: 14.sp)),
                  SizedBox(height: 15.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: TextField(
                      controller: code,
                      obscureText: _cacher,
                      onChanged: (value) {
                        // AJOUT 14: Réactiver le scanner si le champ est vidé
                        if (value.isEmpty && !_scannerActive) {
                          setState(() {
                            _scannerActive = true;
                          });
                        }
                      },
                      decoration: InputDecoration(
                          label: Text("Code tontine", style: TextStyle(fontSize: 16.sp)),
                          filled: true,
                          fillColor: Couleur.lightGray,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: Couleur.primaryBlue)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Couleur.primaryBlue),
                              borderRadius: BorderRadius.circular(12.r)),
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _cacher = !_cacher;
                              });
                              // CORRECTION 7: Masquage automatique optionnel
                              if (!_cacher) {
                                Future.delayed(Duration(seconds: 3), () {
                                  if (mounted) { // AJOUT 15: Vérification mounted
                                    setState(() {
                                      _cacher = true;
                                    });
                                  }
                                });
                              }
                            },
                            child: _cacher ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                          )),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  // CORRECTION 8: Bouton avec loading state
                  Row(
                    children: [
                      TextButton.icon(
                          onPressed: _isLoading ? null : () {
                            participer();
                          },
                          label: _isLoading
                              ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text("Participation...", style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                            ],
                          )
                              : Text("Participer", style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                          icon: _isLoading ? SizedBox.shrink() : Icon(Icons.rocket_launch, color: Colors.white),
                          style: _buttonStyle),
                      TextButton.icon(
                          onPressed: _isLoading ? null : () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => creer_tontine(listsession: widget.listsession)));
                          },
                          style: _buttonStyle, // CORRECTION 10: Style factorisé
                          label: Text("Créer ma tontine", style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                          icon: Icon(Icons.rocket_launch, color: Colors.white))
                    ],
                  ),
                ],
              ))
        ],
      ),
    );
  }
}