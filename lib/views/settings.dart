import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/icon.dart';
import '../services/storage/secure_storage_service.dart';
import '../../generated/l10n.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _secureStorage = SecureStorageService();
  bool _isLoading = true;
  bool _isBiometricLoading = false;
  bool _isNotificationsLoading = false;
  bool _isLogoutLoading = false;

  @override
  void initState() {
    super.initState();
    developer.log('Initializing AccountSettingsScreen',
        name: 'AccountSettings');
    _setupListeners();
    _initializeAndLoadSettings();
  }

  Future<void> _initializeAndLoadSettings() async {
    await AppConfig.initializeSettings();
    await _loadSettings();
  }

  void _setupListeners() {
    AppConfig.listenToChanges(
      onLanguageChanged: _onSettingsChanged,
      onThemeChanged: _onSettingsChanged,
    );
  }

  void _onSettingsChanged() {
    if (mounted) {
      developer.log('Settings changed, updating UI', name: 'AccountSettings');
      setState(() {});
    }
  }

  @override
  void dispose() {
    AppConfig.removeListeners(
      onLanguageChanged: _onSettingsChanged,
      onThemeChanged: _onSettingsChanged,
    );
    developer.log('Disposing AccountSettingsScreen', name: 'AccountSettings');
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final strings = S.of(context);
    developer.log('Loading settings', name: 'AccountSettings');
    try {
      await AppConfig.loadSettings().timeout(const Duration(seconds: 5),
          onTimeout: () {
        throw TimeoutException('Settings load timed out');
      });
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      developer.log('Failed to load settings: $e',
          name: 'AccountSettings', level: 1000);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorLoadSettings}: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: CustomAppBar.appBarWithTitle(
        screenTitle: strings.titleAccountSettings,
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: Theme.of(context).primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    strings.labelLoading,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: context.textPrimaryColor,
                        ),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(strings.sectionAccount),
                      _buildCardSection([
                        _buildSettingsItem(
                          icon: CustomIcons.personIcon(context),
                          title: strings.optionMyAccount,
                          subtitle: strings.subtitleMyAccount,
                          onTap: () =>
                              _navigateTo(context, AppRoutes.userProfile),
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSettingsItem(
                          icon: CustomIcons.lockIcon(context),
                          title: strings.optionTouchId,
                          subtitle: strings.subtitleTouchId,
                          trailingIcon: _isBiometricLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Switch(
                                  activeColor: Theme.of(context).primaryColor,
                                  value: AppConfig.isBiometricEnabled,
                                  onChanged: (value) => _toggleBiometric(value),
                                ),
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSettingsItem(
                          icon: CustomIcons.logoutIcon(context),
                          title: strings.optionLogout,
                          subtitle: strings.subtitleLogout,
                          onTap: _showLogoutConfirmationDialog,
                        ),
                      ]),
                      const SizedBox(height: 12),
                      _buildSectionHeader(strings.sectionPreferences),
                      _buildCardSection([
                        _buildSettingsItem(
                          icon: CustomIcons.languageIcon(context),
                          title: strings.optionLanguage,
                          subtitle:
                              AppConfig.getLanguageText(AppConfig.language),
                          onTap: _showLanguageSelectionDialog,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSettingsItem(
                          icon: CustomIcons.themeIcon(context),
                          title: strings.optionTheme,
                          subtitle: AppConfig.getThemeText(AppConfig.theme),
                          onTap: _showThemeSelectionDialog,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSettingsItem(
                          icon: CustomIcons.notificationsIcon(context),
                          title: strings.optionNotifications,
                          subtitle: AppConfig.isNotificationsEnabled
                              ? strings.enabled
                              : strings.disabled,
                          trailingIcon: _isNotificationsLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Switch(
                                  activeColor: Theme.of(context).primaryColor,
                                  value: AppConfig.isNotificationsEnabled,
                                  onChanged: (value) =>
                                      _toggleNotifications(value),
                                ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      _buildSectionHeader(strings.sectionSupport),
                      _buildCardSection([
                        _buildSettingsItem(
                          icon: CustomIcons.helpIcon(context),
                          title: strings.optionHelpSupport,
                          subtitle: strings.subtitleHelpSupport,
                          onTap: () =>
                              _handleNotImplemented(strings.optionHelpSupport),
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSettingsItem(
                          icon: CustomIcons.aboutIcon(context),
                          title: strings.optionAboutApp,
                          subtitle: strings.subtitleAboutApp,
                          onTap: () =>
                              _handleNotImplemented(strings.optionAboutApp),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      _buildSectionHeader(strings.sectionLegal),
                      _buildCardSection([
                        _buildSettingsItem(
                          icon: CustomIcons.privacyIcon(context),
                          title: strings.optionPrivacyPolicy,
                          onTap: () => _handleNotImplemented(
                              strings.optionPrivacyPolicy),
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSettingsItem(
                          icon: CustomIcons.termsIcon(context),
                          title: strings.optionTermsOfService,
                          onTap: () => _handleNotImplemented(
                              strings.optionTermsOfService),
                        ),
                      ]),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimaryColor,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  Widget _buildCardSection(List<Widget> children) {
    return Card(
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required Widget icon,
    required String title,
    String? subtitle,
    Widget? trailingIcon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      leading: icon,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: context.textPrimaryColor,
            ),
      ),
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.textSecondaryColor,
                    ),
              ),
            )
          : null,
      trailing: trailingIcon ??
          Icon(Icons.chevron_right,
              color: context.textSecondaryColor, size: 20),
      onTap: onTap,
      tileColor: context.secondaryCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Adjust the radius as needed
      ),
    );
  }

  Future<void> _toggleBiometric(bool value) async {
    final strings = S.of(context);
    setState(() => _isBiometricLoading = true);
    try {
      final result = await AppConfig.setBiometricEnabled(value);
      if (mounted) {
        if (result.isSuccess) {
          HapticFeedback.lightImpact();
          developer.log('Biometric setting updated to: $value',
              name: 'AccountSettings');
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.toggleBiometricSuccess),
              backgroundColor: AppColors.success,
              behavior: Theme.of(context).snackBarTheme.behavior,
              shape: Theme.of(context).snackBarTheme.shape,
            ),
          );
        } else {
          throw Exception(result.error ?? 'Unknown error');
        }
      }
    } catch (e) {
      developer.log('Failed to update biometric: $e',
          name: 'AccountSettings', level: 1000);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorGeneric}: $e'),
            backgroundColor: AppColors.error,
            behavior: Theme.of(context).snackBarTheme.behavior,
            shape: Theme.of(context).snackBarTheme.shape,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBiometricLoading = false);
      }
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final strings = S.of(context);
    setState(() => _isNotificationsLoading = true);
    try {
      final result = await AppConfig.setNotificationsEnabled(value);
      if (mounted) {
        if (result.isSuccess) {
          HapticFeedback.lightImpact();
          developer.log('Notifications setting updated to: $value',
              name: 'AccountSettings');
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.toggleNotificationsSuccess),
              backgroundColor: AppColors.success,
              behavior: Theme.of(context).snackBarTheme.behavior,
              shape: Theme.of(context).snackBarTheme.shape,
            ),
          );
        } else {
          throw Exception(result.error ?? 'Unknown error');
        }
      }
    } catch (e) {
      developer.log('Failed to update notifications: $e',
          name: 'AccountSettings', level: 1000);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorGeneric}: $e'),
            backgroundColor: AppColors.error,
            behavior: Theme.of(context).snackBarTheme.behavior,
            shape: Theme.of(context).snackBarTheme.shape,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isNotificationsLoading = false);
      }
    }
  }

  void _navigateTo(BuildContext context, String route) {
    developer.log('Navigating to $route', name: 'AccountSettings');
    Navigator.pushNamed(context, route).catchError((e) {
      developer.log('Navigation error to $route: $e',
          name: 'AccountSettings', level: 1000);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${S.of(context).errorNavigation}: $e'),
          backgroundColor: AppColors.error,
          behavior: Theme.of(context).snackBarTheme.behavior,
          shape: Theme.of(context).snackBarTheme.shape,
        ),
      );
    });
  }

  void _handleNotImplemented(String feature) {
    developer.log('$feature tapped - not implemented', name: 'AccountSettings');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).messageNotImplemented)),
    );
  }

  void _showLanguageSelectionDialog() {
    final strings = S.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          strings.dialogTitleSelectLanguage,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
              ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: context.cardColor,
        content: SizedBox(
          width: double.maxFinite,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLanguageOption(dialogContext, 'en',
                      strings.languageEnglish, setDialogState),
                  _buildLanguageOption(dialogContext, 'hi',
                      strings.languageHindi, setDialogState),
                  _buildLanguageOption(dialogContext, 'mr',
                      strings.languageMarathi, setDialogState),
                ],
              );
            },
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: CustomButtons.secondaryButton(
                  text: strings.buttonCancel,
                  onPressed: () => Navigator.pop(dialogContext),
                  height: 48,
                  context: context,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButtons.primaryButton(
                  text: strings.buttonApply,
                  onPressed: () => Navigator.pop(dialogContext),
                  height: 48,
                  context: context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext dialogContext, String code,
      String name, StateSetter setDialogState) {
    final isSelected = AppConfig.language == code;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          developer.log('Language option $code tapped',
              name: 'AccountSettings');
          final result = await AppConfig.setLanguage(code);
          if (result.isSuccess) {
            HapticFeedback.selectionClick();
            developer.log('Language set to $code', name: 'AccountSettings');
            setDialogState(() {});
          } else {
            developer.log('Failed to set language: ${result.error}',
                name: 'AccountSettings', level: 1000);
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              SnackBar(
                  content: Text(
                      '${S.of(dialogContext).errorGeneric}: ${result.error}')),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? context.textPrimaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                      color: context.textPrimaryColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeSelectionDialog() {
    final strings = S.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          strings.dialogTitleChooseTheme,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
              ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: context.cardColor,
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThemeCard(
                      dialogContext,
                      AppThemeMode.light,
                      strings.themeLight,
                      Icons.light_mode_outlined,
                      setDialogState),
                  const SizedBox(height: 8),
                  _buildThemeCard(
                      dialogContext,
                      AppThemeMode.dark,
                      strings.themeDark,
                      Icons.dark_mode_outlined,
                      setDialogState),
                  const SizedBox(height: 8),
                  _buildThemeCard(
                      dialogContext,
                      AppThemeMode.system,
                      strings.themeSystem,
                      Icons.brightness_auto,
                      setDialogState),
                ],
              );
            },
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: CustomButtons.secondaryButton(
                  text: strings.buttonCancel,
                  onPressed: () => Navigator.pop(dialogContext),
                  height: 48,
                  context: context,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButtons.primaryButton(
                  text: strings.buttonApply,
                  onPressed: () => Navigator.pop(dialogContext),
                  height: 48,
                  context: context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(BuildContext dialogContext, AppThemeMode themeMode,
      String name, IconData icon, StateSetter setDialogState) {
    final isSelected = AppConfig.theme == themeMode;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? context.borderColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          developer.log('Theme option ${themeMode.value} tapped',
              name: 'AccountSettings');
          final result = await AppConfig.setTheme(themeMode);
          if (result.isSuccess) {
            HapticFeedback.selectionClick();
            developer.log('Theme set to ${themeMode.value}',
                name: 'AccountSettings');
            setDialogState(() {});
          } else {
            developer.log('Failed to set theme: ${result.error}',
                name: 'AccountSettings', level: 1000);
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              SnackBar(
                  content: Text(
                      '${S.of(dialogContext).errorGeneric}: ${result.error}')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Theme.of(context).iconTheme.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                        color: context.textPrimaryColor,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    final strings = S.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            CustomIcons.logoutIcon(context),
            const SizedBox(width: 12),
            Text(
              strings.dialogTitleLogout,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                  ),
            ),
          ],
        ),
        content: Text(
          strings.dialogContentLogout,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.textSecondaryColor,
              ),
        ),
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: CustomButtons.secondaryButton(
                  text: strings.buttonCancel,
                  onPressed: () => Navigator.pop(dialogContext),
                  height: 48,
                  context: context,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButtons.primaryButton(
                  text: strings.buttonLogout,
                  onPressed: _isLogoutLoading ? null : _handleLogout,
                  height: 48,
                  context: context,
                ),
              ),
            ],
          ),
        ],
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final strings = S.of(context);
    setState(() => _isLogoutLoading = true);
    developer.log('Logout initiated', name: 'AccountSettings');
    try {
      await _secureStorage.clearAll();
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.logoutSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.welcome,
          (route) => false,
        );
      }
    } catch (e) {
      developer.log('Logout failed: $e', name: 'AccountSettings', level: 1000);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorGeneric}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLogoutLoading = false);
      }
    }
  }
}
