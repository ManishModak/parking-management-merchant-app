import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/models/notification_model.dart';
import 'package:merchant_app/models/transaction_model.dart';
import 'package:merchant_app/utils/components/icon.dart';
import 'package:merchant_app/viewmodels/notification_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:merchant_app/models/plaza_fare.dart';
import 'dart:developer' as developer;
import '../../generated/l10n.dart';

class CustomCards {
  static Widget plazaCard({
    String? imageUrl,
    required String plazaName,
    required String location,
    required String plazaId,
    VoidCallback? onTap,
    required BuildContext context,
  }) {
    final strings = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 8),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: context.secondaryCardColor,
        child: InkWell(
          onTap: () {
            developer.log('Plaza card tapped: $plazaName', name: 'CustomCards');
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: _buildImageWidget(imageUrl, context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        plazaName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${strings.labelPlazaId} $plazaId",
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.textSecondaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildImageWidget(String? imageUrl, BuildContext context) {
    final customCacheManager = CacheManager(
      Config(
        'plazaImageCache',
        stalePeriod: const Duration(hours: 24),
        maxNrOfCacheObjects: 100,
      ),
    );
    final strings = S.of(context);

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.image_not_supported,
          size: 40,
          color: context.textSecondaryColor,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: customCacheManager,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.shimmerBaseLight
            : AppColors.shimmerBaseDark,
        highlightColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.shimmerHighlightLight
            : AppColors.shimmerHighlightDark,
        direction: ShimmerDirection.ltr,
        period: const Duration(milliseconds: 1200),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.shimmerBaseLight
                : AppColors.shimmerBaseDark,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: BoxDecoration(
          color: AppColors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.error_outline,
          size: 40,
          color: AppColors.error,
        ),
      ),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
    );
  }

  static Widget menuCard({
    required String menu,
    VoidCallback? onTap,
    required BuildContext context,
  }) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.only(top: 8.0),
      width: AppConfig.deviceWidth * 0.9,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: context.cardColor,
        child: InkWell(
          onTap: () {
            developer.log('Menu card tapped: $menu', name: 'CustomCards');
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    menu,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: context.textPrimaryColor,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: context.textSecondaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget addCard({
    VoidCallback? onTap,
    double? width,
    double? height,
    required BuildContext context,
  }) {
    final strings = S.of(context);
    return SizedBox(
      width: width,
      height: height ?? 80,
      child: Card(
        elevation: 0,
        color: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            developer.log('Add card tapped', name: 'CustomCards');
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Icon(
              Icons.add,
              size: 24,
              color: context.textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }

  static Widget userProfileCard({
    required String name,
    required String userId,
    String? imageUrl,
    VoidCallback? onTap,
    required BuildContext context,
  }) {
    final strings = S.of(context);
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 5,
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: context.inputBorderColor, width: 2), // Use theme-aware border
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: context.surfaceColor,
              child: imageUrl == null || imageUrl.isEmpty
                  ? Icon(Icons.person, size: 50, color: Theme.of(context).brightness == Brightness.light ? AppColors.primary : AppColors.secondary)
                  : null,
              backgroundImage: imageUrl != null && imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${strings.labelUserId} $userId",
                    style: TextStyle(fontSize: 16, color: context.textSecondaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget notificationCard({
    required NotificationModel notification,
    required BuildContext context,
  }) {
    final strings = S.of(context);
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: AppColors.textLight),
      ),
      onDismissed: (direction) {
        context.read<NotificationsViewModel>().deleteNotification(notification.id);
        developer.log('Notification dismissed: ${notification.title}', name: 'CustomCards');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: context.secondaryCardColor, // Use theme-aware notification color
          child: ListTile(
            leading: CustomIcons.buildNotificationIcon(notification, context),
            title: Text(
              notification.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w500,
                color: context.textPrimaryColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: context.textSecondaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTimeAgo(notification.timestamp, strings),
                  style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                ),
              ],
            ),
            onTap: () {
              developer.log('Notification tapped: ${notification.title}', name: 'CustomCards');
              _handleNotificationTap(context, notification);
            },
          ),
        ),
      ),
    );
  }

  static void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    if (!notification.isRead) {
      context.read<NotificationsViewModel>().markAsRead(notification.id);
    }
    switch (notification.type) {
      case NotificationType.newBooking:
        if (notification.bookingId != null) {
          Navigator.pushNamed(context, '/booking-details', arguments: notification.bookingId);
        }
        break;
      case NotificationType.disputeRaised:
      case NotificationType.disputeResolved:
        Navigator.pushNamed(context, '/dispute-details', arguments: notification.bookingId);
        break;
      case NotificationType.plazaAlert:
        if (notification.plazaId != null) {
          Navigator.pushNamed(context, '/plaza-details', arguments: notification.plazaId);
        }
        break;
      default:
        break;
    }
  }

  static String _getTimeAgo(DateTime timestamp, S strings) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays > 7) {
      final formatter = DateFormat('MMM d, y');
      return formatter.format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}${strings.labelDaysAgo}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${strings.labelHoursAgo}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${strings.labelMinutesAgo}';
    } else {
      return strings.labelJustNow;
    }
  }

  static Widget transactionCard({
    required TransactionModel transaction,
    required BuildContext context,
  }) {
    final strings = S.of(context);
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: context.secondaryCardColor,
      child: ListTile(
        title: Text(
          transaction.title,
          style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimaryColor),
        ),
        subtitle: Text(
          '${transaction.amount}',
          style: TextStyle(color: context.textSecondaryColor),
        ),
        trailing: Icon(
          transaction.type == TransactionType.payment ? Icons.arrow_downward : Icons.arrow_upward,
          color: transaction.type == TransactionType.payment ? AppColors.success : AppColors.error,
        ),
        onTap: () {
          developer.log('Transaction card tapped: ${transaction.title}', name: 'CustomCards');
        },
      ),
    );
  }

  static Widget plazaImageCard({
    final List<String>? imageUrls,
    final VoidCallback? onTap,
    required BuildContext context,
  }) {
    final strings = S.of(context);
    return Container(
      width: AppConfig.deviceWidth,
      height: AppConfig.deviceHeight * 0.2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 5,
        color: context.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: context.inputBorderColor, width: 2), // Use theme-aware border
        ),
        child: InkWell(
          onTap: () {
            developer.log('Plaza image card tapped', name: 'CustomCards');
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (imageUrls != null && imageUrls.isNotEmpty)
                  Expanded(
                    child: SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) => Container(
                          width: 60,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(imageUrls[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      width: 60,
                      height: AppConfig.deviceHeight * 0.15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.grey,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: context.textSecondaryColor,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                addCard(
                  height: AppConfig.deviceHeight * 0.15,
                  width: AppConfig.deviceWidth * 0.2,
                  context: context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget plazaInfoCard({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    VoidCallback? onConfirm,
    required IconData icon,
    required BuildContext context,
  }) {
    final strings = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: true,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: context.textPrimaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.inputBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.inputBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.primary
                    : AppColors.secondary,
                width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        style: TextStyle(color: context.textPrimaryColor),
      ),
    );
  }

  static Widget operatorCard({
    required String? imageUrl,
    required String operatorName,
    required String role,
    required String contactNumber,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final strings = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: context.cardColor,
        child: InkWell(
          onTap: () {
            developer.log('Operator card tapped: $operatorName', name: 'CustomCards');
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildOperatorImage(imageUrl, context),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        operatorName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contactNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.textSecondaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildOperatorImage(String? imageUrl, BuildContext context) {
    final customCacheManager = CacheManager(
      Config('operatorImageCache', stalePeriod: const Duration(hours: 24), maxNrOfCacheObjects: 100),
    );
    final strings = S.of(context);

    if (imageUrl == null || imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: context.surfaceColor,
        child: Icon(Icons.person, size: 40, color: Theme.of(context).brightness == Brightness.light ? AppColors.primary : AppColors.secondary),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        cacheManager: customCacheManager,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.shimmerBaseLight
              : AppColors.shimmerBaseDark,
          highlightColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.shimmerHighlightLight
              : AppColors.shimmerHighlightDark,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.shimmerBaseLight
                  : AppColors.shimmerBaseDark,
              shape: BoxShape.circle,
            ),
          ),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.grey,
          child: Icon(Icons.person, size: 40, color: AppColors.error),
        ),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  static Widget fareCard({
    required PlazaFare fare,
    required String plazaName,
    required VoidCallback onTap,
    required BuildContext context,
    required S strings, // Added strings parameter
  }) {
    // Determine fare details string based on fare type
    String fareDetails = '';
    String timeDetails = ''; // For progressive range or hour-wise base hours/discount

    switch (fare.fareType) {
      case FareTypes.progressive:
        fareDetails = '${strings.labelFareAmount}: ₹${fare.fareRate.toStringAsFixed(2)}'; // "Fare: ₹X.XX"
        timeDetails = '${strings.labelTimeRange}: ${fare.from ?? '?'} - ${fare.toCustom ?? '?'} ${strings.labelMinutesAbbr}'; // "Range: X - Y min"
        break;
      case FareTypes.freePass:
        fareDetails = strings.fareTypeFreePass; // "Free Pass"
        timeDetails = ''; // No extra details
        break;
      case FareTypes.daily:
        fareDetails = '₹${fare.fareRate.toStringAsFixed(2)} / ${strings.labelDay}'; // "₹X.XX / Day"
        break;
      case FareTypes.hourly:
        fareDetails = '₹${fare.fareRate.toStringAsFixed(2)} / ${strings.labelHour}'; // "₹X.XX / Hour"
        break;
      case FareTypes.monthlyPass:
        fareDetails = '₹${fare.fareRate.toStringAsFixed(2)} / ${strings.labelMonth}'; // "₹X.XX / Month"
        break;
      case FareTypes.hourWiseCustom:
        fareDetails = '${strings.labelBaseRate}: ₹${fare.fareRate.toStringAsFixed(2)} / ${strings.labelHour}'; // "Base: ₹X.XX / Hour"
        timeDetails = '${strings.labelBaseHours}: ${fare.baseHours ?? '-'}'; // "Base Hours: X"
        if (fare.discountRate != null && fare.discountRate! > 0) {
          // Add discount info if present and positive
          timeDetails += '\n${strings.labelDiscount}: ${fare.discountRate}%'; // "Discount: Y%"
        }
        break;
      default:
      // Fallback for unknown types (shouldn't happen ideally)
        fareDetails = '${strings.labelRate}: ₹${fare.fareRate.toStringAsFixed(2)}'; // "Rate: ₹X.XX"
    }

    return Card(
      margin: EdgeInsets.zero, // Keep margin as is unless specified otherwise
      elevation: Theme.of(context).cardTheme.elevation ?? 2, // Use theme elevation
      shape: Theme.of(context).cardTheme.shape ?? RoundedRectangleBorder( // Use theme shape
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: fare.isDeleted
              ? AppColors.error.withOpacity(0.3) // Use defined AppColors more prominently
              : AppColors.success.withOpacity(0.3), // Use defined AppColors
          width: 1,
        ),
      ),
      color: context.cardColor, // Use theme extension
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          developer.log('Fare card tapped for plaza: $plazaName, Fare ID: ${fare.fareId}', name: 'CustomCards');
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Plaza Name and Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.labelPlazaName, // Label text
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: context.textSecondaryColor, // Use theme secondary color
                                ),
                              ),
                              Text(
                                plazaName, // Plaza name value
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimaryColor, // Use theme primary color
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8), // Space before status
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: fare.isDeleted
                                ? AppColors.error.withOpacity(0.1)
                                : AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            fare.isDeleted ? strings.labelInactive : strings.labelActive,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: fare.isDeleted ? AppColors.error : AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 2: Vehicle Type and Fare Type
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.labelVehicleType,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: context.textSecondaryColor,
                                ),
                              ),
                              Text(
                                fare.vehicleType,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.labelFareType,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: context.textSecondaryColor,
                                ),
                              ),
                              Text(
                                fare.fareType,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 3: Fare/Time Details and Effective Period
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // Dynamic label based on content
                                fare.fareType == FareTypes.progressive ? strings.labelDetails : strings.labelFareDetails,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: context.textSecondaryColor,
                                ),
                              ),
                              Text(
                                fareDetails, // The calculated fare string
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold, // Make rate bold
                                  color: context.textPrimaryColor,
                                ),
                              ),
                              // Show time details if present (Progressive, Hour-wise)
                              if (timeDetails.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  timeDetails,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: context.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.labelEffectivePeriod,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: context.textSecondaryColor,
                                ),
                              ),
                              Text(
                                // Format dates, use 'Ongoing' if end date is null
                                '${DateFormat('dd MMM yyyy').format(fare.startEffectDate)} - ${fare.endEffectDate != null ? DateFormat('dd MMM yyyy').format(fare.endEffectDate!) : strings.labelOngoing}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Keep chevron for navigation indication
              Container(
                width: 30,
                alignment: Alignment.center,
                child: Icon(
                    Icons.chevron_right,
                    color: context.textSecondaryColor, // Use secondary color for less emphasis
                    size: Theme.of(context).iconTheme.size ?? 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}