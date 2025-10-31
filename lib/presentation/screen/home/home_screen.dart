import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_advance/configuration/constants.dart';
import 'package:flutter_bloc_advance/configuration/local_storage.dart';
import 'package:flutter_bloc_advance/data/repository/account_repository.dart';
import 'package:flutter_bloc_advance/utils/app_constants.dart';
import 'package:flutter_bloc_advance/data/repository/login_repository.dart';
import 'package:flutter_bloc_advance/routes/app_routes_constants.dart';
import 'package:go_router/go_router.dart';

import '../../common_blocs/account/account.dart';
// Minimal home per plan: remove dashboard/drawer/top widgets

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    debugPrint("HomeScreen _buildBody theme: ${AppLocalStorageCached.theme}");
    return BlocProvider(
      create: (context) {
        //debugPrint("HomeScreen account blocProvider");
        return AccountBloc(repository: AccountRepository())..add(const AccountFetchEvent());
      },
      child: BlocBuilder<AccountBloc, AccountState>(
        buildWhen: (previous, current) {
          return current.status != previous.status;
          // if(previous.status != current.status) {
          //   debugPrint("HomeScreen account bloc builder: ${current.status}");
          // }
          // return current.account != null;
        },
        builder: (context, state) {
          debugPrint("HomeScreen account bloc builder: ${state.status}");
          if (state.status == AccountStatus.success) {
            return Scaffold(
              appBar: AppBar(title: const Text(AppConstants.appName)),
              key: _scaffoldKey,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome to Lidya '
                              '${(AppLocalStorageCached.firstName ?? '')} '
                              '${(AppLocalStorageCached.lastName ?? '')}'
                          .trim(),
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(AppLocalStorageCached.username ?? state.data?.email ?? '', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () async {
                        // Clear storage and logout
                        final loginRepo = LoginRepository();
                        await loginRepo.logout();
                        if (context.mounted) {
                          context.go(ApplicationRoutesConstants.login);
                        }
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.status == AccountStatus.loading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (state.status == AccountStatus.failure) {
            // When account load fails (e.g., missing/expired token), send user to login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.go(ApplicationRoutesConstants.login);
              }
            });
            return const Scaffold(body: SizedBox.shrink());
          }
          debugPrint("Unexpected state : ${state.toString()}");
          return const Scaffold(body: SizedBox.shrink());
          // }
        },
      ),
    );
  }

  Widget backgroundImage(BuildContext context) {
    // dark or light mode row decoration
    if (Theme.of(context).brightness == Brightness.dark) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(200),
          child: Container(
            height: 300,
            width: 300,
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage(LocaleConstants.logoLightUrl), scale: 1, fit: BoxFit.contain),
            ),
          ),
        ),
      );
    } else {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(LocaleConstants.defaultImgUrl),
                colorFilter: ColorFilter.mode(
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withAlpha(128)
                      : Colors.white.withAlpha(128),
                  BlendMode.dstIn,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  // Drawer removed for minimal template
}
