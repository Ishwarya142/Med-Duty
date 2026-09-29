import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum ScheduleCallType { videoCall, voiceCall, interview, consultation }

class ScheduleCallBottomSheet extends StatefulWidget {
  final ScheduleCallType callType;
  final String contactName;
  final String? contactImage;
  final Function(
    DateTime scheduledDateTime,
    ScheduleCallType type,
    String title,
  )?
  onSchedule;

  const ScheduleCallBottomSheet({
    super.key,
    required this.callType,
    required this.contactName,
    this.contactImage,
    this.onSchedule,
  });

  static Future<void> show({
    required BuildContext context,
    required ScheduleCallType callType,
    required String contactName,
    String? contactImage,
    Function(DateTime scheduledDateTime, ScheduleCallType type, String title)?
    onSchedule,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleCallBottomSheet(
        callType: callType,
        contactName: contactName,
        contactImage: contactImage,
        onSchedule: onSchedule,
      ),
    );
  }

  @override
  State<ScheduleCallBottomSheet> createState() =>
      _ScheduleCallBottomSheetState();
}

class _ScheduleCallBottomSheetState extends State<ScheduleCallBottomSheet> {
  late FixedExtentScrollController _dateController;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _ampmController;

  late DateTime _now;
  late DateTime _minDate;
  late DateTime _maxDate;
  late DateTime _selectedDate;
  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedAmPm;

  final List<String> _weekdays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];
  final List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final List<String> _ampm = ['AM', 'PM'];

  final TextEditingController _titleController = TextEditingController();

  List<DateTime> _dates = [];

  @override
  void initState() {
    super.initState();

    _now = DateTime.now();
    _minDate = _now.add(const Duration(hours: 1));
    _maxDate = _now.add(const Duration(days: 90));

    _selectedDate = DateTime(_minDate.year, _minDate.month, _minDate.day);
    _selectedHour = _minDate.hour > 12
        ? _minDate.hour - 12
        : (_minDate.hour == 0 ? 12 : _minDate.hour);
    _selectedMinute = ((_minDate.minute / 5).ceil() * 5) % 60;
    _selectedAmPm = _minDate.hour >= 12 ? 1 : 0;

    _dates = [];
    for (
      var d = DateTime(_maxDate.year, _maxDate.month, _maxDate.day);
      !d.isBefore(DateTime(_minDate.year, _minDate.month, _minDate.day));
      d = d.subtract(const Duration(days: 1))
    ) {
      _dates.insert(0, d);
    }

    final initialDateIndex = _dates.indexWhere(
      (d) =>
          d.year == _selectedDate.year &&
          d.month == _selectedDate.month &&
          d.day == _selectedDate.day,
    );

    _dateController = FixedExtentScrollController(
      initialItem: initialDateIndex >= 0 ? initialDateIndex : 0,
    );
    _hourController = FixedExtentScrollController(
      initialItem: _selectedHour - 1,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute ~/ 5,
    );
    _ampmController = FixedExtentScrollController(initialItem: _selectedAmPm);

    final callTitle = switch (widget.callType) {
      ScheduleCallType.videoCall => 'Video call with ${widget.contactName}',
      ScheduleCallType.voiceCall => 'Voice call with ${widget.contactName}',
      ScheduleCallType.interview => 'Interview - ${widget.contactName}',
      ScheduleCallType.consultation =>
        'Consultation with ${widget.contactName}',
    };
    _titleController.text = callTitle;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _ampmController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  DateTime _getScheduledDateTime() {
    int hour24 = _selectedHour;
    if (_selectedAmPm == 1 && _selectedHour != 12) hour24 += 12;
    if (_selectedAmPm == 0 && _selectedHour == 12) hour24 = 0;
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour24,
      _selectedMinute,
    );
  }

  String _getCallLabel() {
    return switch (widget.callType) {
      ScheduleCallType.videoCall => 'Schedule Video Call',
      ScheduleCallType.voiceCall => 'Schedule Voice Call',
      ScheduleCallType.interview => 'Schedule Interview',
      ScheduleCallType.consultation => 'Schedule Consultation',
    };
  }

  IconData _getCallIcon() {
    return switch (widget.callType) {
      ScheduleCallType.videoCall => Icons.videocam_rounded,
      ScheduleCallType.voiceCall => Icons.call_rounded,
      ScheduleCallType.interview => Icons.work_outline_rounded,
      ScheduleCallType.consultation => Icons.medical_services_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final surfaceVariant = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSurfaceVariant;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkGrey : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: textColor,
                        size: 26,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text(
                      _getCallLabel(),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 26),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppColors.lightPrimaryGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                _getCallIcon(),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.contactName,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_getScheduledDateTime().difference(_now).inDays} days from now',
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Call title',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _titleController,
                        style: TextStyle(color: textColor, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Add a title...',
                          hintStyle: TextStyle(color: textSecondary),
                          filled: true,
                          fillColor: surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.accent,
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () => _titleController.clear(),
                            icon: Icon(
                              Icons.cancel,
                              color: textSecondary,
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'Start time',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: AppColors.accent,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${_weekdays[_selectedDate.weekday % 7]}, ${_months[_selectedDate.month - 1]} ${_selectedDate.day}  ·  ${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} ${_ampm[_selectedAmPm]}',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: textSecondary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Choose a time between 3 months from today and 1 hour from now.',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 210,
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceVariant.withValues(
                                          alpha: 0.6,
                                        )
                                      : AppColors.lightSurfaceVariant
                                            .withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: ListWheelScrollView.useDelegate(
                                    controller: _dateController,
                                    itemExtent: 38,
                                    perspective: 0.003,
                                    physics: const FixedExtentScrollPhysics(),
                                    onSelectedItemChanged: (i) {
                                      if (i < _dates.length) {
                                        setState(
                                          () => _selectedDate = _dates[i],
                                        );
                                      }
                                    },
                                    childDelegate: ListWheelChildBuilderDelegate(
                                      childCount: _dates.length,
                                      builder: (context, i) {
                                        if (i < 0 || i >= _dates.length)
                                          return const SizedBox();
                                        final d = _dates[i];
                                        final isToday =
                                            d.year == _now.year &&
                                            d.month == _now.month &&
                                            d.day == _now.day;
                                        return Center(
                                          child: Text(
                                            isToday
                                                ? 'Today'
                                                : '${_weekdays[d.weekday % 7]} ${_months[d.month - 1]} ${d.day}',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ListWheelScrollView.useDelegate(
                                    controller: _hourController,
                                    itemExtent: 38,
                                    perspective: 0.003,
                                    physics: const FixedExtentScrollPhysics(),
                                    onSelectedItemChanged: (i) {
                                      setState(() => _selectedHour = i + 1);
                                    },
                                    childDelegate:
                                        ListWheelChildBuilderDelegate(
                                          childCount: 12,
                                          builder: (context, i) {
                                            return Center(
                                              child: Text(
                                                '${i + 1}',
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ListWheelScrollView.useDelegate(
                                    controller: _minuteController,
                                    itemExtent: 38,
                                    perspective: 0.003,
                                    physics: const FixedExtentScrollPhysics(),
                                    onSelectedItemChanged: (i) {
                                      setState(() => _selectedMinute = i * 5);
                                    },
                                    childDelegate: ListWheelChildBuilderDelegate(
                                      childCount: 12,
                                      builder: (context, i) {
                                        return Center(
                                          child: Text(
                                            '${(i * 5).toString().padLeft(2, '0')}',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ListWheelScrollView.useDelegate(
                                    controller: _ampmController,
                                    itemExtent: 38,
                                    perspective: 0.003,
                                    physics: const FixedExtentScrollPhysics(),
                                    onSelectedItemChanged: (i) {
                                      setState(() => _selectedAmPm = i);
                                    },
                                    childDelegate:
                                        ListWheelChildBuilderDelegate(
                                          childCount: 2,
                                          builder: (context, i) {
                                            return Center(
                                              child: Text(
                                                _ampm[i],
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            final scheduled = _getScheduledDateTime();
                            widget.onSchedule?.call(
                              scheduled,
                              widget.callType,
                              _titleController.text.trim(),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.accent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                content: Text(
                                  'Scheduled for ${_weekdays[scheduled.weekday % 7]}, ${_months[scheduled.month - 1]} ${scheduled.day} at ${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} ${_ampm[_selectedAmPm]}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadowColor: AppColors.accent.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          child: Text(
                            'Done',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
