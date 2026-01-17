import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/welcome_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logos.png',
                    width: 120,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Sentral Nurulhuda\nSistem manajemen Nurulhuda",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "DAFTAR",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F3D26),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xff0F3D26),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "WELCOME",
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Sentral Nurulhuda\nSistem manajemen Nurulhuda",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Sudah Punya Akun?",
                      style: TextStyle(color: Colors.white),
                    ),
                    InkWell(
                      onTap: controller.toLogin,
                      child: const Row(
                        children: [
                          Text("Masuk", style: TextStyle(color: Colors.white)),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
