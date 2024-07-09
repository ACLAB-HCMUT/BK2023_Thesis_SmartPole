import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class LightingSchedulePage extends StatefulWidget {
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
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;
  String recurrenceType = 'None';
  String recurrenceRule0 = '';

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Add New Event'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: eventNameController,
                    decoration:
                    const InputDecoration(labelText: 'Event Name'),
                  ),
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(startDate != null
                        ? '${startDate!.year}-${startDate!.month}-${startDate!.day}'
                        : 'Select Start Date'),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != startDate) {
                        setState(() {
                          startDate = pickedDate;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text(startTime != null
                        ? '${startTime!.hour}:${startTime!.minute}'
                        : 'Select Start Time'),
                    onTap: () async {
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
                  ),
                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(endDate != null
                        ? '${endDate!.year}-${endDate!.month}-${endDate!.day}'
                        : 'Select End Date'),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != endDate) {
                        setState(() {
                          endDate = pickedDate;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('End Time'),
                    subtitle: Text(endTime != null
                        ? '${endTime!.hour}:${endTime!.minute}'
                        : 'Select End Time'),
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null && pickedTime != endTime) {
                        setState(() {
                          endTime = pickedTime;
                        });
                      }
                    },
                  ),
                  DropdownButton<String>(
                    value: recurrenceType,
                    onChanged: (String? newValue) {
                      setState(() {
                        recurrenceType = newValue!;
                      });
                    },
                    items: <String>[
                      'None',
                      'Daily',
                      'Weekly',
                      'Monthly',
                      'Yearly'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  if (recurrenceType == 'Weekly')
                    ListTile(
                      title: const Text('Day of Week'),
                      subtitle: Text(recurrenceRule0),
                      onTap: () async {
                        final pickedDay = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: const Text('Select Day of Week'),
                              children: <Widget>[
                                SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.pop(context, 'SU');
                                  },
                                  child: const Text('Sunday'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.pop(context, 'MO');
                                  },
                                  child: const Text('Monday'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.pop(context, 'TU');
                                  },
                                  child: const Text('Tuesday'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.pop(context, 'WE');
                                  },
                                  child: const Text('Wednesday'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.pop(context, 'TH');
                                  },
                                  child: const Text('Thursday'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.pop(context, 'FR');
                                  },
                                  child: const Text('Friday'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.pop(context, 'SA');
                                  },
                                  child: const Text('Saturday'),
                                ),
                              ],
                            );
                          },
                        );
                        if (pickedDay != null &&
                            pickedDay != recurrenceRule0) {
                          setState(() {
                            recurrenceRule0 = pickedDay;
                          });
                        }
                      },
                    ),
                  if (recurrenceType == 'Monthly')
                    TextField(
                      controller: recurrenceRuleController,
                      decoration:
                      const InputDecoration(labelText: 'Day of Month'),
                      keyboardType: TextInputType.number,
                    ),
                  if (recurrenceType == 'Yearly')
                    ListTile(
                      title: const Text('Month and Day'),
                      subtitle: Text(recurrenceRule0),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            recurrenceRule0 =
                            '${pickedDate.month}-${pickedDate.day}';
                          });
                        }
                      },
                    ),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                ],
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
                  if (startDate != null &&
                      startTime != null &&
                      endDate != null &&
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
                          'FREQ=WEEKLY;BYDAY=$recurrenceRule0;INTERVAL=1';
                          break;
                        case 'Monthly':
                          recurrenceRule =
                          'FREQ=MONTHLY;BYMONTHDAY=${recurrenceRuleController.text};INTERVAL=1';
                          break;
                        case 'Yearly':
                          final parts = recurrenceRule0.split('-');
                          final month = parts[0];
                          final day = parts[1];
                          recurrenceRule =
                          'FREQ=YEARLY;BYMONTH=$month;BYMONTHDAY=$day';
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