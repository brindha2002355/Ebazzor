import 'dart:io';
import 'package:BidNBuy/utils/constant.dart';
import 'package:BidNBuy/utils/extensions/extensions.dart';
import 'package:BidNBuy/utils/login/apple_login/apple_login.dart';
import 'package:BidNBuy/utils/login/email_login/email_login.dart';
import 'package:BidNBuy/utils/login/google_login/google_login.dart';
import 'package:BidNBuy/utils/login/phone_login/phone_login.dart';
import 'package:BidNBuy/utils/login/lib/login_system.dart';
import 'package:BidNBuy/utils/helper_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:BidNBuy/utils/login/lib/login_status.dart';
import 'package:BidNBuy/utils/login/lib/payloads.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthenticationType {
  email,
  google,
  apple,
  phone;
}

abstract class AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationInProcess extends AuthenticationState {
  final AuthenticationType type;

  AuthenticationInProcess(this.type);
}

class AuthenticationSuccess extends AuthenticationState {
  final AuthenticationType type;
  final UserCredential credential;
  final LoginPayload payload;

  AuthenticationSuccess(this.type, this.credential, this.payload);
}

class AuthenticationFail extends AuthenticationState {
  final dynamic error;

  AuthenticationFail(this.error);
}

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationInitial());
  AuthenticationType? type;
  LoginPayload? payload;
  MMultiAuthentication mMultiAuthentication = MMultiAuthentication({
    "google": GoogleLogin(),
    "email": EmailLogin(),
    if (Platform.isIOS) "apple": AppleLogin(),
    "phone": PhoneLogin()
  });

  void init() {
    mMultiAuthentication.init();
  }

  void setData(
      {required LoginPayload payload, required AuthenticationType type}) {
    this.type = type;
    this.payload = payload;
  }

  void authenticate() async {
    if (type == null && payload == null) {
      return;
    }

    try {
      emit(AuthenticationInProcess(type!));
      mMultiAuthentication.setActive(type!.name);
      mMultiAuthentication.payload = MultiLoginPayload({
        type!.name: payload!,
      });

      UserCredential? credential = await mMultiAuthentication.login();


      LoginPayload? payloadData = (payload);

      if (payloadData is EmailLoginPayload &&
          payloadData.type == EmailLoginType.login) {
        if (credential != null) {
          User? user = credential.user;
          if (user != null && !user.emailVerified) {
            // Handle the case when the user's email is not verified
            emit(AuthenticationFail(HelperUtils.showSnackBarMessage(
                Constant.navigatorKey.currentContext,
                "pleaseFirstVerifyUser"
                    .translate(Constant.navigatorKey.currentContext!))));
          } else {
            emit(AuthenticationSuccess(type!, credential,payload!));
          }
        }
      } else {
        emit(AuthenticationSuccess(type!, credential!,payload!));
      }
    } catch (e) {


      print(" ///////////////////////////");
      print("🔥 Authentication Failed: $e");
      print(" ///////////////////////////");

      emit(AuthenticationFail(e));
    }
  }

  void listen(Function(MLoginState state) fn) {
    mMultiAuthentication.listen(fn);
  }

  void verify() {
    mMultiAuthentication.setActive(type!.name);
    mMultiAuthentication.payload = MultiLoginPayload({
      type!.name: payload!,
    });
    mMultiAuthentication.requestVerification();
  }
}








