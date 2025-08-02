import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/lane.dart'; // Keep if validateLaneDetails is used elsewhere
import 'package:merchant_app/models/plaza.dart';

class PlazaFormValidation {
  String? validateBasicDetails(BuildContext context, Map<String, dynamic> data,
      Map<String, String?> errors) {
    final strings = S.of(context);
    developer.log(
        '[PlazaFormValidation] Starting Basic Details validation. Data: $data',
        name: 'PlazaFormValidation.validateBasicDetails');
    errors.clear(); // Start fresh for each validation run
    bool hasError = false;

    // Define validation configurations
    // Key: map key used in BasicDetailsViewModel.basicDetails
    // Value: Tuple (Display Name for error message, minLength, maxLength)
    final requiredTextFields = {
      // *** ADDED plazaId Validation ***
      'plazaId': ('Plaza ID', 6, 6),
      // Required, Exact length 6
      // --- End Added ---
      'plazaName': ('Plaza name', 3, 100),
      'companyName': ('Company name', 1, 20),
      'plazaOrgId': ('Plaza Org ID', 4, 5),
      'email': ('Email', 5, 100),
      // Keeping minLength 5 as per original code
      'address': ('Address', 10, 200),
      'city': ('City', 3, 50),
      'district': ('District', 3, 50),
      'state': ('State', 3, 50),
      // Plaza Owner is often handled separately via logged-in user, but if editable:
      // 'plazaOwner': ('Plaza Owner Name', 3, 100), // Keep commented unless needed
    };

    // Key: map key
    // Value: Tuple (Display Name, minDigits, maxDigits, minValue, maxValue, isRequired)
    final numericFields = {
      'mobileNumber': ('Mobile number', 10, 15, null, null, true),
      'pincode': ('Pincode', 6, 6, null, null, true),
      // Exact length 6
      'noOfParkingSlots': ('Total parking slots', null, null, 1, null, true),
      // Min 1 slot
      'capacityBike': ('Bike capacity', null, null, 0, null, false),
      'capacity3Wheeler': ('3-Wheeler capacity', null, null, 0, null, false),
      'capacity4Wheeler': ('4-Wheeler capacity', null, null, 0, null, false),
      'capacityBus': ('Bus capacity', null, null, 0, null, false),
      'capacityTruck': ('Truck capacity', null, null, 0, null, false),
      'capacityHeavyMachinaryVehicle': (
        'Heavy machinery capacity',
        null,
        null,
        0,
        null,
        false
      ),
    };

    // Key: map key
    // Value: Tuple (Display Name, min Value, max Value)
    final coordinateFields = {
      'geoLatitude': ('Latitude', -90.0, 90.0),
      'geoLongitude': ('Longitude', -180.0, 180.0),
    };

    // Key: map key
    // Value: Tuple (Display Name, List<String> validOptions, isRequired)
    final dropdownFields = {
      'companyType': ('Company type', Plaza.validCompanyTypes, true),
      'plazaCategory': ('Plaza category', Plaza.validPlazaCategories, true),
      'plazaSubCategory': (
        'Plaza sub category',
        Plaza.validPlazaSubCategories,
        true
      ),
      'structureType': ('Structure type', Plaza.validStructureTypes, true),
      'plazaStatus': ('Plaza status', Plaza.validPlazaStatuses, true),
      'priceCategory': ('Price category', Plaza.validPriceCategories, true),
    };

    // Key: map key
    // Value: Display Name
    final timingFields = {
      'plazaOpenTimings': 'Opening time',
      'plazaClosingTime': 'Closing time',
    };

    // Key: map key
    // Value: Display Name
    final booleanFields = {
      'freeParking': 'Free parking status',
    };

    // --- Start Validation Logic ---

    // 1. Required Text Fields (Length & Format)
    requiredTextFields.forEach((key, config) {
      final value = data[key]?.toString().trim() ?? '';
      final (String fieldName, int minLength, int maxLength) =
          config; // Use pattern matching

      if (value.isEmpty) {
        errors[key] = strings.validationRequired(fieldName);
        hasError = true;
      } else if (value.length < minLength) {
        errors[key] = strings.validationMinLength(fieldName, minLength);
        hasError = true;
      } else if (value.length > maxLength) {
        // Check if exact length is required (min == max)
        if (minLength == maxLength) {
          errors[key] = strings.validationExactLength(fieldName, minLength);
        } else {
          errors[key] = strings.validationMaxLength(fieldName, maxLength);
        }
        hasError = true;
      } else if (key == 'email' &&
          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        errors[key] = strings.validationInvalidEmail;
        hasError = true;
      }
      // Optional: Add specific format validation for plazaId if needed (e.g., alphanumeric)
      // else if (key == 'plazaId' && !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) { // Example only
      //   errors[key] = strings.validationAlphanumericOnly(fieldName); // Assuming this exists in S class
      //   hasError = true;
      // }
    });

    // 2. Numeric Fields (Format, Digits, Range)
    numericFields.forEach((key, config) {
      final valueStr = data[key]?.toString().trim() ?? '';
      final (fieldName, minDigits, maxDigits, minValue, maxValue, isRequired) =
          config;

      if (valueStr.isEmpty) {
        if (isRequired) {
          errors[key] = strings.validationRequired(fieldName);
          hasError = true;
        }
      } else if (!RegExp(r'^\d+$').hasMatch(valueStr)) {
        errors[key] = strings.validationDigitsOnly(fieldName);
        hasError = true;
      } else {
        // Check lengths
        if (minDigits != null && valueStr.length < minDigits) {
          errors[key] = strings.validationMinDigits(fieldName, minDigits);
          hasError = true;
        }
        // Use exact length check if min/max are the same
        if (maxDigits != null &&
            minDigits == maxDigits &&
            valueStr.length != minDigits) {
          errors[key] = strings.validationExactLength(
              fieldName, minDigits!); // Use existing message
          hasError = true;
        } else if (maxDigits != null && valueStr.length > maxDigits) {
          errors[key] = strings.validationMaxDigits(fieldName, maxDigits);
          hasError = true;
        }

        // Check numeric range only if previous checks passed
        if (!errors.containsKey(key) &&
            (minValue != null || maxValue != null)) {
          final numValue = int.tryParse(valueStr);
          if (numValue == null) {
            errors[key] = strings.validationInvalidNumber(fieldName);
            hasError = true;
          } else {
            if (minValue != null && numValue < minValue) {
              errors[key] = (minValue == 0)
                  ? strings.validationNonNegative(fieldName)
                  : strings.validationGreaterThanOrEqualTo(fieldName, minValue);
              hasError = true;
            }
            if (maxValue != null && numValue > maxValue) {
              errors[key] =
                  strings.validationLessThanOrEqualTo(fieldName, maxValue);
              hasError = true;
            }
          }
        }
      }
    });

    // 3. Coordinate Fields (Format, Range)
    coordinateFields.forEach((key, config) {
      final valueStr = data[key]?.toString().trim() ?? '';
      final (displayName, minVal, maxVal) = config;

      if (valueStr.isEmpty) {
        errors[key] = strings.validationRequired(displayName);
        hasError = true;
      } else if (!RegExp(r'^-?(\d+(\.\d*)?|\.\d+)$').hasMatch(valueStr)) {
        errors[key] = strings.validationInvalidNumber(displayName);
        hasError = true;
      } else {
        final numValue = double.tryParse(valueStr);
        if (numValue == null) {
          errors[key] = strings.validationInvalidNumber(displayName);
          hasError = true;
        } else if (numValue < minVal || numValue > maxVal) {
          errors[key] = strings.validationRange(displayName, minVal, maxVal);
          hasError = true;
        }
      }
    });

    // 4. Dropdown Fields (Selection Required, Valid Option)
    dropdownFields.forEach((key, config) {
      final value = data[key]?.toString().trim() ?? '';
      final (fieldName, validOptions, isRequired) = config;
      if (value.isEmpty) {
        if (isRequired) {
          errors[key] = strings.validationSelectRequired(fieldName);
          hasError = true;
        }
      } else if (!validOptions.contains(value)) {
        errors[key] =
            strings.validationInvalidOption(fieldName, validOptions.join(', '));
        hasError = true;
        developer.log(
            '[PlazaFormValidation] Invalid dropdown value "$value" for $key. Allowed: ${validOptions.join(', ')}',
            name: 'PlazaFormValidation',
            level: 900);
      }
    });

    // 5. Timing Fields (Format)
    timingFields.forEach((key, fieldName) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.isEmpty) {
        errors[key] = strings.validationRequired(fieldName);
        hasError = true;
      } else if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
        errors[key] = strings.validationInvalidTimeFormat;
        hasError = true;
      }
    });

    // 6. Boolean Fields (Presence check)
    booleanFields.forEach((key, fieldName) {
      final value = data[key];
      if (value == null || value is! bool) {
        errors[key] = strings.validationBooleanRequired(fieldName);
        hasError = true;
        developer.log(
            '[PlazaFormValidation] Boolean field "$key" is null or not a boolean. Value: $value',
            name: 'PlazaFormValidation',
            level: 900);
      }
    });

    // --- Business Logic Validations ---

    // 7. Parking Slot Consistency
    final parkingKeys = [
      'noOfParkingSlots',
      'capacityBike',
      'capacity3Wheeler',
      'capacity4Wheeler',
      'capacityBus',
      'capacityTruck',
      'capacityHeavyMachinaryVehicle'
    ];
    bool allParkingFieldsHaveValidFormat =
        parkingKeys.every((key) => !errors.containsKey(key));

    if (allParkingFieldsHaveValidFormat) {
      final totalSlotsStr = data['noOfParkingSlots']?.toString().trim() ?? '';
      final totalSlots = int.tryParse(totalSlotsStr);

      final bikeSlots =
          int.tryParse(data['capacityBike']?.toString().trim() ?? '0') ?? 0;
      final threeWheelerSlots =
          int.tryParse(data['capacity3Wheeler']?.toString().trim() ?? '0') ?? 0;
      final fourWheelerSlots =
          int.tryParse(data['capacity4Wheeler']?.toString().trim() ?? '0') ?? 0;
      final busSlots =
          int.tryParse(data['capacityBus']?.toString().trim() ?? '0') ?? 0;
      final truckSlots =
          int.tryParse(data['capacityTruck']?.toString().trim() ?? '0') ?? 0;
      final heavyMachinarySlots = int.tryParse(
              data['capacityHeavyMachinaryVehicle']?.toString().trim() ??
                  '0') ??
          0;
      final totalIndividualSlots = bikeSlots +
          threeWheelerSlots +
          fourWheelerSlots +
          busSlots +
          truckSlots +
          heavyMachinarySlots;

      if (totalSlots == null && totalSlotsStr.isNotEmpty) {
        errors['noOfParkingSlots'] ??=
            strings.validationInvalidNumber('Total parking slots');
        hasError = true;
      } else if (totalSlots != null) {
        if (totalSlots != totalIndividualSlots) {
          errors['noOfParkingSlots'] ??= strings.validationParkingSlotEqual(
              totalSlots, totalIndividualSlots);
          hasError = true;
        }
      } else {
        bool anyCapacityEntered = totalIndividualSlots > 0;
        if (anyCapacityEntered) {
          errors['noOfParkingSlots'] ??= strings.validationRequired(
              'Total parking slots (when capacities are entered)');
          hasError = true;
        }
      }
    }

    // 8. Time Order Validation (Closing > Opening)
    bool bothTimesValidFormat = !errors.containsKey('plazaOpenTimings') &&
        !errors.containsKey('plazaClosingTime');
    if (bothTimesValidFormat) {
      final openingTimeStr = data['plazaOpenTimings']?.toString().trim() ?? '';
      final closingTimeStr = data['plazaClosingTime']?.toString().trim() ?? '';
      if (openingTimeStr.isNotEmpty && closingTimeStr.isNotEmpty) {
        final openingTime = _parseTimeString(openingTimeStr);
        final closingTime = _parseTimeString(closingTimeStr);
        if (openingTime != null && closingTime != null) {
          final openingMinutes = _timeOfDayToMinutes(openingTime);
          final closingMinutes = _timeOfDayToMinutes(closingTime);
          if (closingMinutes <= openingMinutes) {
            errors['plazaClosingTime'] = strings.validationClosingAfterOpening;
            hasError = true;
          }
        }
      }
    }

    // --- Final Result ---
    developer.log(
        '[PlazaFormValidation] Basic Details Validation completed. hasError=$hasError, errors=$errors',
        name: 'PlazaFormValidation.validateBasicDetails');
    return hasError
        ? (errors['general'] ?? strings.validationGeneralError)
        : null;
  }

  // --- Other Validation Methods (Unchanged) ---
  String? validateBankDetails(BuildContext context, Map<String, dynamic> data,
      Map<String, String?> errors) {
    // ... (implementation remains unchanged) ...
    final strings = S.of(context);
    developer.log(
        '[PlazaFormValidation] Starting Bank Details validation. Data: $data',
        name: 'PlazaFormValidation.validateBankDetails');
    errors.clear(); // Start fresh
    bool hasError = false;

    final requiredFields = {
      'bankName': ('Bank name', 3, 100),
      'accountHolderName': ('Account holder name', 3, 100),
      'accountNumber': ('Account number', 8, 20),
      // Adjust range as needed
      'IFSCcode': ('IFSC code', 11, 11),
      // Use TitleCase key here to match VM map
    };

    // 1. Required Fields (Length Check)
    requiredFields.forEach((key, config) {
      // Read data using the key defined in requiredFields map
      final value = data[key]?.toString().trim() ?? '';
      final (fieldName, minLength, maxLength) = config;
      if (value.isEmpty) {
        errors[key] = strings
            .validationRequired(fieldName); // Assign error using the same key
        hasError = true;
      } else if (value.length < minLength) {
        errors[key] = strings.validationMinLength(fieldName, minLength);
        hasError = true;
      } else if (value.length > maxLength) {
        // Use exact length check specifically for IFSC if maxLength == minLength
        if (key == 'IFSCcode' &&
            minLength == maxLength &&
            value.length != minLength) {
          errors[key] = strings.validationExactLength(fieldName, minLength);
        } else {
          // Check max length for other fields
          errors[key] = strings.validationMaxLength(fieldName, maxLength);
        }
        hasError = true; // Mark error if any length condition fails
      }
    });

    // 2. Specific Format Checks (IFSC, Account Number) only if required/length passed
    final ifscValue = data['IFSCcode']?.toString().trim() ?? '';
    if (ifscValue.isNotEmpty && !errors.containsKey('IFSCcode')) {
      // Check format: 4 letters, 1 zero, 6 alphanumeric (case-insensitive check might be better depending on backend)
      if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$')
          .hasMatch(ifscValue.toUpperCase())) {
        // Check uppercase version
        errors['IFSCcode'] = strings
            .validationInvalidIfscFormat; // Assign error using correct key
        hasError = true;
        developer.log(
            '[PlazaFormValidation] IFSC format validation failed for: $ifscValue',
            name: 'PlazaFormValidation');
      }
    }

    final accountNumValue = data['accountNumber']?.toString().trim() ?? '';
    // Check only if it passed the required/length checks from the loop
    if (accountNumValue.isNotEmpty && !errors.containsKey('accountNumber')) {
      if (!RegExp(r'^\d+$').hasMatch(accountNumValue)) {
        errors['accountNumber'] =
            strings.validationDigitsOnly('Account number');
        hasError = true;
        developer.log(
            '[PlazaFormValidation] Account number format validation failed (non-digits).',
            name: 'PlazaFormValidation');
      }
    }

    developer.log(
        '[PlazaFormValidation] Bank Details Validation completed. hasError=$hasError, errors=$errors',
        name: 'PlazaFormValidation.validateBankDetails');
    // Return general error message if any specific error occurred
    return hasError
        ? (errors['general'] ?? strings.validationGeneralBankError)
        : null;
  }

  String? validateLaneDetails(BuildContext context, Map<String, dynamic> data,
      Map<String, String?> errors) {
    // ... (implementation remains unchanged) ...
    final strings = S.of(context);
    developer.log('[PlazaFormValidation] Validating Lane Details. Data: $data',
        name: 'PlazaFormValidation.validateLaneDetails');
    errors.clear();
    bool hasError = false;

    final requiredFields = {
      'LaneName': 'Lane name',
      'LaneDirection': 'Lane direction',
      'LaneType': 'Lane type',
      'LaneStatus': 'Lane status',
    };

    final maxLengths = {
      'LaneName': ('Lane name', 50),
      'RFIDReaderID': ('RFID Reader ID', 100),
      'CameraID': ('Camera ID', 100),
      'WIMID': ('WIM ID', 100),
      'BoomerBarrierID': ('Boomer Barrier ID', 100),
      'LEDScreenID': ('LED Screen ID', 100),
      'MagneticLoopID': ('Magnetic Loop ID', 100),
    };

    requiredFields.forEach((key, fieldName) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.isEmpty) {
        errors[key] = strings.validationRequired(fieldName);
        hasError = true;
      }
    });

    maxLengths.forEach((key, config) {
      final value = data[key]?.toString().trim() ?? '';
      final (fieldName, maxLength) = config;
      if (value.isNotEmpty && value.length > maxLength) {
        errors[key] = strings.validationMaxLength(fieldName, maxLength);
        hasError = true;
      }
    });

    final laneDirection =
        data['LaneDirection']?.toString().trim().toUpperCase() ?? '';
    if (laneDirection.isNotEmpty && !errors.containsKey('LaneDirection')) {
      if (!Lane.validDirections.contains(laneDirection)) {
        errors['LaneDirection'] = strings.validationInvalidOption(
            'Lane direction', Lane.validDirections.join(', '));
        hasError = true;
      }
    }

    final laneType = data['LaneType']?.toString().trim().toLowerCase() ?? '';
    if (laneType.isNotEmpty && !errors.containsKey('LaneType')) {
      if (!Lane.validTypes.contains(laneType)) {
        errors['LaneType'] = strings.validationInvalidOption(
            'Lane type', Lane.validTypes.join(', '));
        hasError = true;
      }
    }

    final laneStatus =
        data['LaneStatus']?.toString().trim().toLowerCase() ?? '';
    if (laneStatus.isNotEmpty && !errors.containsKey('LaneStatus')) {
      if (!Lane.validStatuses.contains(laneStatus)) {
        errors['LaneStatus'] = strings.validationInvalidOption(
            'Lane status', Lane.validStatuses.join(', '));
        hasError = true;
      }
    }

    developer.log(
        '[PlazaFormValidation] Lane Details Validation completed. hasError=$hasError, errors=$errors',
        name: 'PlazaFormValidation.validateLaneDetails');
    return hasError
        ? (errors['general'] ?? strings.validationGeneralLaneError)
        : null;
  }

  // --- Helper Methods (Unchanged) ---
  TimeOfDay? _parseTimeString(String? timeStr) {
    // ... (implementation remains unchanged) ...
    if (timeStr == null ||
        !RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(timeStr)) {
      return null;
    }
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      developer.log(
          '[PlazaFormValidation] Error parsing time string "$timeStr": $e',
          error: e,
          name: '_parseTimeString');
      return null;
    }
  }

  int _timeOfDayToMinutes(TimeOfDay time) {
    // ... (implementation remains unchanged) ...
    return time.hour * 60 + time.minute;
  }
}
