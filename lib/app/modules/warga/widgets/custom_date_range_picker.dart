import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';

class CustomDateRangePicker extends StatefulWidget {
  final List<DateTime> disabledDates;
  final Function(DateTime startDate, DateTime endDate) onSelectRange;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final int? maxDays; // Maximum allowed days between start and end date
  final Function? onClearSelection; // Callback when selection is cleared
  final bool singleDateMode; // When true, only allows selecting a single date

  const CustomDateRangePicker({
    super.key,
    required this.disabledDates,
    required this.onSelectRange,
    this.initialStartDate,
    this.initialEndDate,
    this.maxDays,
    this.onClearSelection,
    this.singleDateMode = false,
  });

  @override
  _CustomDateRangePickerState createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  late DateTime _currentMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _hoverDate;
  bool _selectionMode =
      false; // true means selecting end date, false means selecting start date

  // Map for O(1) lookup of disabled dates
  late Set<String> _disabledDateStrings;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _selectionMode = _startDate != null && _endDate == null;

    // Create a set of strings from disabled dates for faster lookup
    _disabledDateStrings = {};
    for (var date in widget.disabledDates) {
      _disabledDateStrings.add('${date.year}-${date.month}-${date.day}');
    }
  }

  // Check if a date is disabled
  bool _isDisabled(DateTime date) {
    final dateString = '${date.year}-${date.month}-${date.day}';
    return _disabledDateStrings.contains(dateString);
  }

  // Check if a date is before today or is today
  bool _isBeforeToday(DateTime date) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    // Return true if date is before today (not including today)
    return checkDate.isBefore(todayDate);
  }

  // Check if a date can be selected
  bool _canSelectDate(DateTime date) {
    return !_isDisabled(date) && !_isBeforeToday(date);
  }

  // Get the status of a date (start, end, in-range, disabled, normal)
  String _getDateStatus(DateTime date) {
    if (_isDisabled(date) || _isBeforeToday(date)) {
      return 'disabled';
    }

    if (_startDate != null && _isSameDay(date, _startDate!)) {
      return 'start';
    }

    if (_endDate != null && _isSameDay(date, _endDate!)) {
      return 'end';
    }

    if (_startDate != null &&
        _endDate != null &&
        date.isAfter(_startDate!) &&
        date.isBefore(_endDate!)) {
      return 'in-range';
    }

    return 'normal';
  }

  // Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Handle date tap - now just sets start and optionally end date
  void _onDateTap(DateTime date) {
    if (!_canSelectDate(date)) return;

    setState(() {
      // If we're in single date mode, simply set both start and end date to the selected date
      if (widget.singleDateMode) {
        // If tapping on the already selected date, clear the selection
        if (_startDate != null && _isSameDay(date, _startDate!)) {
          _startDate = null;
          _endDate = null;
          _selectionMode = false;
          if (widget.onClearSelection != null) {
            widget.onClearSelection!();
          }
        } else {
          // Set both start and end date to the selected date
          _startDate = date;
          _endDate = date;

          // Immediately confirm selection in single date mode
          Future.microtask(() => _confirmSelection());
        }
        return;
      }

      // Regular date range selection behavior (for non-single date mode)
      // If tapping on the start date when already selected
      if (_startDate != null && _isSameDay(date, _startDate!)) {
        // If only start date is selected, clear selection
        if (_endDate == null) {
          _startDate = null;
          _selectionMode = false;
          if (widget.onClearSelection != null) {
            widget.onClearSelection!();
          }
          return;
        }
        // If both dates are selected, move end date to start and clear end date
        else if (!_isSameDay(_startDate!, _endDate!)) {
          _startDate = _endDate;
          _endDate = null;
          _selectionMode = true;
          return;
        }
        // If both dates are the same, clear both
        else {
          _startDate = null;
          _endDate = null;
          _selectionMode = false;
          if (widget.onClearSelection != null) {
            widget.onClearSelection!();
          }
          return;
        }
      }

      // If tapping on the end date when already selected
      if (_endDate != null && _isSameDay(date, _endDate!)) {
        // Clear end date but keep start date
        _endDate = null;
        _selectionMode = true;
        return;
      }

      if (!_selectionMode) {
        // Selecting start date
        _startDate = date;
        _endDate = null;
        _selectionMode = true;
      } else {
        // Selecting end date
        if (date.isBefore(_startDate!)) {
          // If selecting a date before start, swap them
          _endDate = _startDate;
          _startDate = date;
        } else {
          // Check if the selection exceeds the maximum allowed days
          if (widget.maxDays != null) {
            final daysInRange = date.difference(_startDate!).inDays + 1;
            if (daysInRange > widget.maxDays!) {
              // Show a message about exceeding the maximum days
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Maksimal ${widget.maxDays} hari! Anda memilih $daysInRange hari.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              return; // Don't proceed with the selection
            }
          }

          _endDate = date;
        }

        // Check if any date in the range is disabled (only if we have an end date)
        if (_endDate != null && !_isSameDay(_startDate!, _endDate!)) {
          _checkRangeForDisabledDates();
        }
      }
    });
  }

  // Check if range contains any disabled dates
  bool _checkRangeForDisabledDates() {
    if (_startDate == null || _endDate == null) return false;

    bool hasDisabledDate = false;
    for (
      DateTime d = _startDate!;
      !d.isAfter(_endDate!);
      d = d.add(const Duration(days: 1))
    ) {
      if (d != _startDate && d != _endDate && _isDisabled(d)) {
        hasDisabledDate = true;
        break;
      }
    }

    if (hasDisabledDate) {
      // Reset selection if range contains disabled date
      _endDate = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rentang tanggal mengandung tanggal yang tidak tersedia',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return true;
    }
    return false;
  }

  // Confirm the selection (either single day or range)
  void _confirmSelection() {
    if (_startDate == null) return;

    // If no end date is selected, use start date as end date
    _endDate ??= _startDate;

    // Now notify the parent widget
    widget.onSelectRange(_startDate!, _endDate!);
  }

  // Generate the calendar for a month
  Widget _buildCalendarMonth(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final dayOfWeek = firstDayOfMonth.weekday % 7; // 0 = Sunday, 6 = Saturday

    // Headers for days of week
    final daysOfWeek = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Column(
      children: [
        // Month and year header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            DateFormat('MMMM yyyy', 'id_ID').format(month),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),

        // Days of week header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              daysOfWeek
                  .map(
                    (day) => SizedBox(
                      width: 36,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),

        const SizedBox(height: 8),

        // Calendar days grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: (dayOfWeek + daysInMonth),
          itemBuilder: (context, index) {
            // Empty cells for days before the 1st of the month
            if (index < dayOfWeek) {
              return const SizedBox();
            }

            final day = index - dayOfWeek + 1;
            final date = DateTime(month.year, month.month, day);
            final status = _getDateStatus(date);

            return GestureDetector(
              onTap: () => _onDateTap(date),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color:
                      status == 'in-range'
                          ? AppColors.primarySoft
                          : status == 'start' || status == 'end'
                          ? AppColors.primary
                          : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Date number
                    Text(
                      day.toString(),
                      style: TextStyle(
                        color:
                            status == 'disabled'
                                ? Colors.grey.shade400
                                : status == 'start' || status == 'end'
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                        fontWeight:
                            status == 'start' || status == 'end'
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Get selection status text
  String? _getSelectionStatusText() {
    if (widget.singleDateMode) {
      if (_startDate == null) {
        return 'Silakan pilih tanggal untuk sewa per jam';
      } else {
        return 'Tanggal dipilih: ${DateFormat('dd MMM yyyy', 'id_ID').format(_startDate!)}';
      }
    }

    if (_startDate == null) {
      return 'Pilih tanggal mulai'; // Guide user to select start date
    } else if (_endDate == null) {
      return 'Tanggal mulai: ${DateFormat('dd MMM yyyy', 'id_ID').format(_startDate!)} - Pilih tanggal akhir atau konfirmasi untuk sewa satu hari';
    } else {
      if (_isSameDay(_startDate!, _endDate!)) {
        return 'Satu hari dipilih: ${DateFormat('dd MMM yyyy', 'id_ID').format(_startDate!)}';
      } else {
        final int days = _endDate!.difference(_startDate!).inDays + 1;
        return '${DateFormat('dd MMM yyyy', 'id_ID').format(_startDate!)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(_endDate!)} ($days hari)';
      }
    }
  }

  // Check if a date can be highlighted as potential end date during hover
  bool _canBeEndDate(DateTime date) {
    if (!_canSelectDate(date)) return false;
    if (_startDate == null) return false;

    // If date is before start date, it can't be an end date
    if (date.isBefore(_startDate!)) return false;

    // Check if the range would exceed the maximum days
    if (widget.maxDays != null) {
      final daysInRange = date.difference(_startDate!).inDays + 1;
      if (daysInRange > widget.maxDays!) return false;
    }

    // Check if any dates in the range are disabled
    for (
      DateTime d = _startDate!;
      !d.isAfter(date);
      d = d.add(const Duration(days: 1))
    ) {
      if (!_isSameDay(d, _startDate!) &&
          !_isSameDay(d, date) &&
          _isDisabled(d)) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selection status - only shown when a date is selected
        Builder(
          builder: (context) {
            final statusText = _getSelectionStatusText();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                statusText ?? 'Pilih tanggal untuk memesan',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),

        // Display current month
        _buildCalendarMonth(_currentMonth),

        // Hint for deselection
        if (_startDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              "Tekan tanggal yang sudah dipilih untuk membatalkan",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        // Month navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month - 1,
                    );
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: AppColors.primary),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
        ),

        // Controls
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                child: const Text('Batal'),
              ),
              // Hide confirm button in single date mode as selection is auto-confirmed
              if (!widget.singleDateMode)
                ElevatedButton(
                  onPressed: _startDate != null ? _confirmSelection : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                  ),
                  child: const Text('Konfirmasi'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
