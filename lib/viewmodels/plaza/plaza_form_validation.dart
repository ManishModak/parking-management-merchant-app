import 'package:flutter/material.dart';

class PlazaFormValidation {
  String? validateBasicDetails(
      Map<String, dynamic> data, Map<String, String?> errors) {
    // Text fields with length constraints
    final requiredTextFields = {
      'plazaName': ('Plaza name', 50),
      'plazaOwner': ('Plaza owner', 50),
      'operatorName': ('Operator name', 50),
      // 'operatorId': ('Operator ID', 20),
      'email': ('Email', null),
      'address': ('Address', 256),
      'city': ('City', 50),
      'district': ('District', 50),
      'state': ('State', 50),
    };

    // Numeric fields with character length constraints
    final numericFields = {
      'totalParkingSlots': ('Total parking slots', (1, 10)),
      'twoWheelerCapacity': ('Two-wheeler capacity', (1, 10)),
      'lmvCapacity': ('LMV capacity', (1, 10)),
      'lcvCapacity': ('LCV capacity', (1, 10)),
      'hmvCapacity': ('HMV capacity', (1, 10)),
      'mobileNumber': ('Mobile number', (10, 10)),
      'pincode': ('Pincode', (6, 6)),
    };

    // Dropdown fields
    final dropdownFields = {
      'plazaCategory': 'Plaza category',
      'structureType': 'Structure type',
      'priceCategory': 'Price category',
      'plazaStatus': 'Plaza status',
      'plazaSubCategory': 'Plaza sub category'
    };

    // Timing fields
    final timingFields = {
      'openingTime': 'Opening Time',
      'closingTime': 'Closing Time'
    };

    bool hasError = false;

    // Validate text fields
    for (final field in requiredTextFields.entries) {
      final value = data[field.key]?.toString().trim() ?? '';
      final (fieldName, maxLength) = field.value;

      if (value.isEmpty) {
        errors[field.key] = '$fieldName is required';
        hasError = true;
        continue;
      }

      if (maxLength != null && value.length > maxLength) {
        errors[field.key] = '$fieldName must not exceed $maxLength characters';
        hasError = true;
        continue;
      }

      // Special validation for email
      if (field.key == 'email' &&
          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        errors[field.key] = 'Please enter a valid email address';
        hasError = true;
      }
    }

    // Validate numeric fields
    for (final field in numericFields.entries) {
      final value = data[field.key]?.toString().trim() ?? '';
      final (fieldName, (minLength, maxLength)) = field.value;

      if (value.isEmpty) {
        errors[field.key] = '$fieldName is required';
        hasError = true;
      } else if (!RegExp(r'^\d+$').hasMatch(value)) {
        errors[field.key] = '$fieldName must contain only digits';
        hasError = true;
      } else if (value.length < minLength || value.length > maxLength) {
        if (minLength == maxLength) {
          errors[field.key] = '$fieldName must be exactly $minLength digits';
        } else {
          errors[field.key] = '$fieldName must be between $minLength and $maxLength digits long';
        }
        hasError = true;
      }
    }

    // Validate geographic coordinates
    // Validate geographic coordinates
    for (final coord in [
      ('latitude', -90.0, 90.0),
      ('longitude', -180.0, 180.0)
    ]) {
      final coordName = coord.$1;
      final minVal = coord.$2;
      final maxVal = coord.$3;
      final value = data[coordName]?.toString().trim() ?? '';
      if (value.isEmpty) {
        errors[coordName] = '${coordName.capitalize()} is required';
        hasError = true;
      } else {
        final num = double.tryParse(value);
        if (num == null) {
          errors[coordName] = '${coordName.capitalize()} must be a valid number';
          hasError = true;
        } else {
          final formattedValue = formatCoordinate(value);
          // Determine allowed digits before decimal based on coordinate type
          final beforeDecimal = coordName == 'latitude' ? 2 : 3;
          if (!_isValidDecimal(formattedValue, beforeDecimal, 8)) {
            errors[coordName] = '${coordName.capitalize()} must be a valid decimal with $beforeDecimal digits before and up to 8 after decimal point';
            hasError = true;
          } else if (num < minVal || num > maxVal) {
            errors[coordName] = '${coordName.capitalize()} must be between $minVal° and $maxVal°';
            hasError = true;
          }
        }
      }
    }

    // Validate dropdown fields
    for (final field in dropdownFields.entries) {
      final value = data[field.key]?.toString().trim() ?? '';
      if (value.isEmpty) {
        errors[field.key] = 'Please select ${field.value.toLowerCase()}';
        hasError = true;
      }
    }


    // Validate timing fields
    for (final field in timingFields.entries) {
      final value = data[field.key]?.toString().trim() ?? '';
      if (value.isEmpty) {
        errors[field.key] = '${field.value} is required';
        hasError = true;
      } else if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
        errors[field.key] = 'Please enter a valid time in HH:mm format';
        hasError = true;
      }
    }

    // Cross validate timing
    if (!errors.containsKey('openingTime') && !errors.containsKey('closingTime')) {
      final openingTime = _parseTimeString(data['openingTime']?.toString() ?? '');
      final closingTime = _parseTimeString(data['closingTime']?.toString() ?? '');

      if (openingTime != null && closingTime != null) {
        final openingMinutes = _timeOfDayToMinutes(openingTime);
        final closingMinutes = _timeOfDayToMinutes(closingTime);

        if (closingMinutes <= openingMinutes) {
          errors['closingTime'] = 'Closing time must be after opening time';
          hasError = true;
        }
      }
    }

    // Cross validate total parking slots
    if (!errors.containsKey('totalParkingSlots') &&
        !errors.containsKey('twoWheelerCapacity') &&
        !errors.containsKey('lmvCapacity') &&
        !errors.containsKey('lcvCapacity') &&
        !errors.containsKey('hmvCapacity')) {

      final totalSlots = int.parse(data['totalParkingSlots'].toString());
      final twoWheelerSlots = int.parse(data['twoWheelerCapacity'].toString());
      final lmvSlots = int.parse(data['lmvCapacity'].toString());
      final lcvSlots = int.parse(data['lcvCapacity'].toString());
      final hmvSlots = int.parse(data['hmvCapacity'].toString());

      final totalIndividualSlots = twoWheelerSlots + lmvSlots + lcvSlots + hmvSlots;
      if (totalSlots != totalIndividualSlots) {
        errors['totalParkingSlots'] =
        'Total slots must equal sum of individual capacities ($totalIndividualSlots)';
        hasError = true;
      }
    }

    return hasError ? 'Please complete all required fields correctly' : null;
  }

  String formatCoordinate(String value) {
    if (!value.contains('.')) {
      value = '$value.0';
    }

    final parts = value.split('.');
    final decimalPart = parts[1].padRight(8, '0');
    return '${parts[0]}.$decimalPart';
  }


  bool _isValidDecimal(String value, int beforeDecimal, int afterDecimal) {
    // Handle whole numbers by adding .0
    if (!value.contains('.')) {
      value = '$value.0';
    }

    final parts = value.split('.');
    if (parts.length != 2) return false;

    final integerPart = parts[0].replaceAll(RegExp(r'^-'), '');
    final decimalPart = parts[1];

    return integerPart.length <= beforeDecimal &&
        decimalPart.length <= afterDecimal &&
        RegExp(r'^\d+$').hasMatch(integerPart) &&
        RegExp(r'^\d+$').hasMatch(decimalPart);
  }

  // Helper methods remain the same
  TimeOfDay? _parseTimeString(String? timeStr) {
    if (timeStr == null) return null;

    final parts = timeStr.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  int _timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  // Bank Details Validation
  String? validateBankDetails(Map<String, dynamic> data, Map<String, String?> errors) {
    bool hasError = false;

    // Bank Name
    final bankName = data['bankName']?.toString().trim() ?? '';
    if (bankName.isEmpty) {
      errors['bankName'] = 'Bank name is required';
      hasError = true;
    } else if (bankName.length > 100) {
      errors['bankName'] = 'Bank name must not exceed 100 characters';
      hasError = true;
    }

    // Account Number
    final accountNumber = data['accountNumber']?.toString().trim() ?? '';
    if (accountNumber.isEmpty) {
      errors['accountNumber'] = 'Account number is required';
      hasError = true;
    } else if (accountNumber.length > 20 || accountNumber.length < 10) {
      errors['accountNumber'] = 'Account number must be between 10 to 20';
      hasError = true;
    }

    // Account Holder Name
    final accountHolderName = data['accountHolderName']?.toString().trim() ?? '';
    if (accountHolderName.isEmpty) {
      errors['accountHolderName'] = 'Account holder name is required';
      hasError = true;
    } else if (accountHolderName.length > 100) {
      errors['accountHolderName'] = 'Account holder name must not exceed 100 characters';
      hasError = true;
    }

    // IFSC Code
    final ifscCode = data['ifscCode']?.toString().trim() ?? '';  // Updated to match Joi schema field name
    if (ifscCode.isEmpty) {
      errors['ifscCode'] = 'IFSC code is required';
      hasError = true;
    } else if (ifscCode.length != 11) {
      errors['ifscCode'] = 'IFSC code must be exactly 11 characters';
      hasError = true;
    } else if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifscCode)) {
      errors['ifscCode'] = 'Invalid IFSC code format';
      hasError = true;
    }

    return hasError ? 'Please correct the errors in Bank Details' : null;
  }

  String? validateLaneDetails(Map<String, dynamic> data, Map<String, String?> errors) {
    bool hasError = false;

    // Lane Name
    final laneName = data['laneName']?.toString().trim() ?? '';
    if (laneName.isEmpty) {
      errors['laneName'] = 'Lane name is required';
      hasError = true;
    } else if (laneName.length > 50) {
      errors['laneName'] = 'Lane name must not exceed 50 characters';
      hasError = true;
    }

    // Lane Direction
    final laneDirection = data['laneDirection']?.toString().trim().toUpperCase() ?? '';
    final validDirections = ['EAST', 'WEST', 'NORTH', 'SOUTH'];
    if (laneDirection.isEmpty) {
      errors['laneDirection'] = 'Lane direction is required';
      hasError = true;
    } else if (!validDirections.contains(laneDirection)) {
      errors['laneDirection'] = 'Invalid lane direction. Must be one of: ${validDirections.join(", ")}';
      hasError = true;
    }

    // Lane Type
    final laneType = data['laneType']?.toString().trim().toLowerCase() ?? '';
    final validTypes = ['entry', 'exit'];
    if (laneType.isEmpty) {
      errors['laneType'] = 'Lane type is required';
      hasError = true;
    } else if (!validTypes.contains(laneType)) {
      errors['laneType'] = 'Invalid lane type. Must be one of: ${validTypes.join(", ")}';
      hasError = true;
    }

    // Lane Status
    final laneStatus = data['laneStatus']?.toString().trim() ?? '';
    final validStatuses = ['active', 'close', 'Temp-Inactive'];
    if (laneStatus.isEmpty) {
      errors['laneStatus'] = 'Lane status is required';
      hasError = true;
    } else if (!validStatuses.contains(laneStatus)) {
      errors['laneStatus'] = 'Invalid lane status. Must be one of: ${validStatuses.join(", ")}';
      hasError = true;
    }

    // Optional Fields with length validation
    final optionalFields = {
      'RFIDReaderID': 'RFID Reader ID',
      'CameraID': 'Camera ID',
      'WIMID': 'WIM ID',
      'BoomerBarrierID': 'Boomer Barrier ID',
      'LEDScreenID': 'LED Screen ID',
      'MagneticLoopID': 'Magnetic Loop ID'
    };

    optionalFields.forEach((key, label) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        if (value.length > 100) {
          errors[key] = '$label must not exceed 100 characters';
          hasError = true;
        }
      }
    });

    // Plaza ID validation (assuming it's still required as per original code)
    final plazaId = data['plazaId']?.toString().trim() ?? '';
    if (plazaId.isEmpty) {
      errors['plazaId'] = 'Plaza ID is required';
      hasError = true;
    }

    return hasError ? 'Please correct the errors in Lane Details' : null;
  }

}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
