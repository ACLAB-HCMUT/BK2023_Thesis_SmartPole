import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_app/widgets/custom_button_choosing_date.dart';
import 'package:flutter_app/AppFunction/get_Day_Of_Week.dart';

class LightingSchedulePage extends StatefulWidget {
  const LightingSchedulePage({super.key});

  @override
  _LightingSchedulePage createState() => _LightingSchedulePage();
}


class _LightingSchedulePage extends State<LightingSchedulePage> {
late List<Appointment> _appointments;
CalendarView _calendarView = CalendarView.month;

@override
void initState() {
  super.initState();
  _appointments = getAppointments();
}

void _changeCalendarView(CalendarView view) {
  setState(() {
    _calendarView = view;
  });
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SfCalendar(
      view: _calendarView,
      headerStyle: const CalendarHeaderStyle(
        textStyle: TextStyle(color: Colors.white, fontSize: 20),
        textAlign: TextAlign.center,
        backgroundColor: Colors.blue,
      ),
      firstDayOfWeek: 1,
      dataSource: AdvertiseDataSource(_appointments),
      allowDragAndDrop: true,
      showNavigationArrow: false,
      showDatePickerButton: true,
      showTodayButton: true,
      allowViewNavigation: false,
      showCurrentTimeIndicator: true,
      allowAppointmentResize: true,
      onTap: _handleCalendarTap,
      monthViewSettings: const MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _showAddEventDialog(context),
      child: const Icon(Icons.add),
    ),
  );
}

void _handleCalendarTap(CalendarTapDetails details) {
  if (details.targetElement == CalendarElement.appointment) {
    final Appointment appointment = details.appointments!.first;
    _showEventDetailsDialog(context, appointment);
    if (_calendarView == CalendarView.month) {
      setState(() {
        _calendarView = CalendarView.day;
      });
    }
  }
}


Future<void> _showAddEventDialog(BuildContext context) async {
  final eventNameController = TextEditingController();
  final recurrenceRuleController = TextEditingController();
  final notesController = TextEditingController();
  DateTimeRange dateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now()
  );
  DateTime? startDate = dateRange.start;
  DateTime? endDate = dateRange.end;
  int? durationDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? recurrenceType;
  String recurrenceRule0 = '';



  final List<String> recurrenceTypeItems = [
    'None',
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Add New Event'),
            content: SingleChildScrollView(
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
                      controller: eventNameController,
                      decoration:
                      const InputDecoration(labelText: 'Event Name'),
                    ),

                    ElevatedButton (
                      onPressed: () async {
                        DateTimeRange? pickedDate = await showDateRangePicker(
                            context: context,
                            initialDateRange: dateRange,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 500,
                                    maxHeight: 600,
                                  ), // Set the desired height
                                  child: Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: child,
                                  ),
                                ),
                              );
                            }
                        );
                        if (pickedDate != null) {
                          setState(() {
                            startDate = dateRange.start;
                            endDate = dateRange.end;
                            durationDate = dateRange.duration.inDays;
                            dateRange = pickedDate;
                          });
                        }
                      },
                      child: Column(
                          children: <Widget> [
                            const Text('Start Date - End Date'),
                            if (durationDate != null) ...[
                              Text(
                                startDate != null
                                    ? '${DateFormat('dd/MM/yyyy').format(startDate!)} - '
                                    'Period: $durationDate Day(s)'
                                    : 'Start Date - End Date',
                                textAlign: TextAlign.center,
                              )
                            ]
                          ]
                      ),
                    ),

                    TextButton(
                      onPressed: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null && pickedTime != startTime) {
                          setState(() {
                            startTime = pickedTime;
                          });
                        }
                      },
                      style: TextButton.styleFrom(
                        minimumSize:const Size(240, 60)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisSize: MainAxisSize.min,
                        children: <Widget> [
                          Text(
                            "Start Time:",
                            textAlign: TextAlign.start,
                            style:
                            TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: startTime == null ? 32.0 : 16.0,
                              decoration: startTime == null ? TextDecoration.none : TextDecoration.underline,
                            ),
                          ),
                          if (startTime != null)...[
                            Text(
                              startTime!.format(context),
                              style: const TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.w900,
                                height: 1
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null && pickedTime != startTime) {
                          setState(() {
                            endTime = pickedTime;
                          });
                        }
                      },
                      child: Column(
                        children: <Widget> [
                          const Text("End Time"),
                          if (endTime != null)...[
                            Text(
                              endTime!.format(context),
                            ),
                          ]
                        ],
                      ),
                    ),


                    DropdownMenu<String>(
                        width: 200,
                        initialSelection: 'None',
                        label: const Text('Select Recurrence Type'),
                        dropdownMenuEntries: recurrenceTypeItems.map((String item) {
                          return DropdownMenuEntry<String>(
                            value: item,
                            label: item,
                          );
                        }).toList(),
                        onSelected: (String? newValue) {
                          setState(() {
                            recurrenceType = newValue!;
                          });
                        }
                    ),

                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Add'),
                onPressed: () {
                  if (startTime != null &&
                      endTime != null) {
                    final DateTime startDateTime = DateTime(
                      startDate!.year,
                      startDate!.month,
                      startDate!.day,
                      startTime!.hour,
                      startTime!.minute,
                    );
                    final DateTime endDateTime = DateTime(
                      endDate!.year,
                      endDate!.month,
                      endDate!.day,
                      endTime!.hour,
                      endTime!.minute,
                    );
                    String recurrenceRule = '';
                    if (recurrenceType != 'None') {
                      switch (recurrenceType) {
                        case 'Daily':
                          recurrenceRule = 'FREQ=DAILY;INTERVAL=1';
                          break;
                        case 'Weekly':
                          recurrenceRule =
                          'FREQ=WEEKLY;BYDAY=${DayOfWeekUtils.getDayOfWeek(startDate!)};INTERVAL=1';
                          break;
                        case 'Monthly':
                          recurrenceRule =
                          'FREQ=MONTHLY;BYMONTHDAY=${dateRange.start.day};INTERVAL=1';
                          break;
                        case 'Yearly':
                          recurrenceRule =
                          'FREQ=YEARLY;BYMONTH=${startDate!.month};BYMONTHDAY=${startDate!.day}';
                          break;
                      }
                    }
                    final newEvent = Appointment(
                      startTime: startDateTime,
                      endTime: endDateTime,
                      subject: eventNameController.text,
                      notes: notesController.text,
                      recurrenceRule: recurrenceRule,
                      color: Colors.blue,
                    );
                    setState(() {
                      _appointments.add(newEvent);
                    });
                    _changeCalendarView(CalendarView.month);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _showEventDetailsDialog(
    BuildContext context, Appointment appointment) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          appointment.subject,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildDetailRow(Icons.access_time, 'Start Time',
                  appointment.startTime.toString()),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.access_time_outlined, 'End Time',
                  appointment.endTime.toString()),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.repeat, 'Recurrence Rule',
                  appointment.recurrenceRule ?? 'None'),
              const SizedBox(height: 10),
              _buildDetailRow(
                  Icons.notes, 'Notes', appointment.notes ?? 'None'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Close',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Widget _buildDetailRow(IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        color: Colors.blue,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

List<Appointment> getAppointments() {
  List<Appointment> meetings = <Appointment>[];
  final DateTime today = DateTime.now();
  final DateTime startTime =
  DateTime(today.year, today.month, today.day, 9, 0, 0);
  final DateTime endTime = startTime.add(const Duration(hours: 2));

  return meetings;
}
}

class AdvertiseDataSource extends CalendarDataSource {
  AdvertiseDataSource(List<Appointment> source) {
    appointments = source;
  }
}