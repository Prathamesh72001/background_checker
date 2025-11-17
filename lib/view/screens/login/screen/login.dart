
import 'package:boxicons/boxicons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/sizes.dart';
import '../../../../constants/strings.dart';
import '../../../../core/router/router.dart';
import '../../../../core/router/routes.dart';
import '../../../common widgets/button_widget.dart';
import '../../../common widgets/edit_text_widget.dart';
import '../../../common widgets/text_widget.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Padding(
        padding: EdgeInsets.all(35 * Sizes.scaleFactor),
        child:SizedBox(
          height: Sizes.screenHeight,
          width: Sizes.screenWidth,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(top: 0, left: 0,child: CommonButtonWidget(onPressed: (){AppRouter.pop();},height: 50, width: 50,tooltip: Strings.back, child: Icon(Boxicons.bx_chevron_left_circle, color: AppColors.textColor,size: 50 * Sizes.scaleFactor),)),
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonTextWidget(text: Strings.welcome_back),

                    CommonTextWidget(text: Strings.login_to_continue.toUpperCase(),textSize: 50),

                    const SizedBox(height: 35),

                    // email
                    CommonTextField(prefixIcon: Icon(Boxicons.bx_at),label: Strings.email, controller: TextEditingController(),keyboardType: TextInputType.emailAddress,),

                    const SizedBox(height: 15),

                    // password
                    CommonTextField(prefixIcon: Icon(Boxicons.bxs_lock),label: Strings.password, controller: TextEditingController(),isPassword: true,),

                    const SizedBox(height: 10),

                    Container(
                      constraints: BoxConstraints(maxWidth: 750),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(),
                          InkWell(
                              onTap: () {

                              },
                              child: CommonTextWidget(text: Strings.forgot_password,textColor: AppColors.subtextColor,)
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Login button
                    CommonButtonWidget(onPressed: (){}, height: 60, width: Sizes.screenWidth,backgroundColor: AppColors.textColor,hoverScale: 1.05,child: CommonTextWidget(text: Strings.login.toUpperCase(),textColor: AppColors.secondaryColor,),),

                    const SizedBox(height: 10),

                    InkWell(
                      onTap: () {
                        AppRouter.pushReplacementNamed(Routes.register);
                      },
                      child: CommonTextWidget(text: Strings.dont_have_an_account,textColor: AppColors.subtextColor,)
                    ),

                    const SizedBox(height: 35),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonButtonWidget(onPressed: (){},height: 100, width: 100,tooltip: "${Strings.login} ${Strings.with_google}", child: Icon(Boxicons.bxl_google_plus_circle, color: AppColors.textColor,size: 100 * Sizes.scaleFactor),),
                        const SizedBox(width: 25),
                        CommonButtonWidget(onPressed: (){},height: 100, width: 100,tooltip: "${Strings.login} ${Strings.with_facebook}", child: Icon(Boxicons.bxl_facebook_circle, color: AppColors.textColor,size: 100 * Sizes.scaleFactor)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
