import 'package:event_manager2/evnt_manger/data/event_data_source.dart';
import 'package:event_manager2/evnt_manger/detail/event_detail.dart';
import 'package:event_manager2/evnt_manger/event_service/event_service.dart';
import 'package:event_manager2/evnt_manger/model/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventView extends StatefulWidget {
  const EventView({super.key});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  final eventService = EventService();
  // Danh sách sự kiện
  List<EventModel> items = [];
  // Tạo CalendarController dể điều khiển SfCalendar
  final calendarController = CalendarController();

  @override
  void initState() {
    super.initState();
    calendarController.view = CalendarView.day;
    loadEvents();
  }

  Future<void> loadEvents() async {
    final events = await eventService.getAllEvents();
    setState(() {
      items = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(al.appTitle),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                calendarController.view = value;
              });
            },
            itemBuilder: (context) => CalendarView.values.map((view) {
              return PopupMenuItem<CalendarView>(
                value: view,
                child: ListTile(
                  title: Text(view.name),
                ),
              );
            }).toList(),
            icon: getCalendarViewIcons(calendarController.view!),
          ),
          IconButton(
            onPressed: () {
              calendarController.displayDate = DateTime.now();
            },
            icon: Icon(Icons.today_outlined),
          ),
          IconButton(
            onPressed: loadEvents,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: SfCalendar(
        controller: calendarController,
        dataSource: EventDataSource(items),
        monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
        onLongPress: (details) {
          if (details.targetElement == CalendarElement.calendarCell) {
            final newEvent = EventModel(
              startTime: details.date!,
              endTime: details.date!.add(const Duration(hours: 1)),
              subject: 'Sự kiện mới',
            );
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return EventDetail(event: newEvent);
            })).then((value) async {
              if (value == true) {
                await loadEvents();
              }
            });
          }
        },
        onTap: (details) {
          if (details.targetElement == CalendarElement.appointment) {
            final EventModel event = details.appointments!.first;
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return EventDetail(event: event);
            })).then((value) async {
              if (value == true) {
                await loadEvents();
              }
            });
          }
        },
      ),
    );
  }

  Icon getCalendarViewIcons(CalendarView view) {
    switch (view) {
      case CalendarView.day:
        return const Icon(Icons.calendar_view_day_outlined);
      case CalendarView.week:
        return const Icon(Icons.calendar_view_week_outlined);
      case CalendarView.workWeek:
        return const Icon(Icons.work_history_outlined);
      case CalendarView.month:
        return const Icon(Icons.calendar_view_month_outlined);
      case CalendarView.schedule:
        return const Icon(Icons.schedule_outlined);
      default:
        return const Icon(Icons.calendar_today_outlined);
    }
  }
}
