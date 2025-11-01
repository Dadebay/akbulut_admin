import 'package:akbulut_admin/app/product/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

import 'package:akbulut_admin/app/modules/nav_bar_page/bindings/nav_bar_page_binding.dart';
import 'package:akbulut_admin/app/modules/nav_bar_page/views/nav_bar_page_view.dart';

import '../../../product/init/packages.dart';

class LoginView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void loginButtonOnTap() {
    if (_formKey.currentState!.validate()) {
      final box = GetStorage();
      String? role;
      if (emailController.text == 'akbulut' && passwordController.text == 'akbulut123') {
        role = 'admin';
      } else if (emailController.text == 'kadr' && passwordController.text == 'kadr12345') {
        role = 'kadr';
      } else if (emailController.text == 'satys' && passwordController.text == 'satys12345') {
        role = 'satys';
      }

      if (role != null) {
        box.write('token', 'a_fake_but_valid_token');
        box.write('role', role);
        Get.offAll(() => NavBarPageView(), binding: NavBarPageBinding());
      } else {
        CustomWidgets.showSnackBar('error_title', 'error_message', Colors.red);
      }
    } else {
      CustomWidgets.showSnackBar('error_title', 'error_message', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(IconConstants.backImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "login_title".tr,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 30),
                          child: Text(
                            "login_subtitle".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'email_hint'.tr,
                            prefixIcon: Icon(IconlyLight.message, color: Colors.grey[600]),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen email adresinizi girin.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'password_hint'.tr,
                            prefixIcon: Icon(IconlyLight.lock, color: Colors.grey[600]),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen şifrenizi girin.';
                            }
                            return null;
                          },
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 15),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loginButtonOnTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorConstants.kPrimaryColor,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: Text(
                              'login_button'.tr,
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              decoration: BoxDecoration(
                color: ColorConstants.kPrimaryColor,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                "AK Bulut HJ",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
