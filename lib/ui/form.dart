import 'dart:async';
import 'package:flutter/material.dart';
import 'package:life_events/model/database_helper.dart';
import 'package:life_events/model/lifeevent.dart';
import 'package:life_events/model/colours.dart';
import 'package:life_events/ui/list.dart';
import 'package:life_events/ui/dialogs.dart';
import 'package:intl/intl.dart';

class LifeEventForm extends StatefulWidget {
  final LifeEvent lifeEvent;
  final bool editMode;

  LifeEventForm({Key key, @required this.lifeEvent, @required this.editMode})
      : super(key: key);

  @override
  _LifeEventFormState createState() => _LifeEventFormState();
}

class _LifeEventFormState extends State<LifeEventForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper.instance;
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerDetails = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String name = "";
  String details = "";
  int type = LifeEvent.typePersonal;
  bool decision = false;

  @override
  void initState() {
    super.initState();
    if (widget.editMode) {
      selectedDate =
          DateFormat("yyyy-MM-dd hh:mm").parse(widget.lifeEvent.theDay);
      controllerName = TextEditingController(text: widget.lifeEvent.name);
      controllerDetails = TextEditingController(text: widget.lifeEvent.details);
      type = widget.lifeEvent.type;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /* pop the date picker when the form loads as it is unlikely that someone
      will want to create an event for today. */
      _selectDate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      appBar: AppBar(
        title: Text('Life Event'),
        backgroundColor: AppColours.appBackgroundColour,
        actions: [
          IconButton(
              icon: Icon(Icons.cancel_outlined),
              onPressed: () {
                showCustomDialog(context, "Cancel this form?",
                        "Do you want to cancel this unsaved form?")
                    .then((val) {
                  if (val) {
                    Navigator.of(context).pop();
                  }
                });
                //Navigator.pop(context);
              }),
        ],
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    Container builtForm = Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${selectedDate.toLocal()}".split(' ')[0],
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today_outlined),
                      onPressed: () => _selectDate(context),
                    ),
                  ]),
              SizedBox(
                height: 10.0,
              ),
              Row ( children: [
              RichText(
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    text: "Name"),
              ),
              ]),
              TextFormField(
                controller: controllerName,
                // The validator receives the text that the user has entered.
                decoration: const InputDecoration(
                  //hintText: 'Something like, \"Mum was born\"...',
                  labelText: 'Something like, \"Mum was born\"...',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a name for this Life Event.';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 10.0,
              ),
            Row ( children: [
              RichText(
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    text: "Details"),
              ),
              ]
            ),
              TextFormField(
                // The validator receives the text that the user has entered.
                controller: controllerDetails,
                decoration: const InputDecoration(
                  //hintText: 'Something like, \"Mum was born\"...',
                  labelText:
                      'Something like, \"Not quite a week after Dad!\"...',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some details for this Life Event.';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 10.0,
              ),
            Row ( children: [
              RichText(
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    text: "Type (choose)"),
              ),
            ]
            ),
              SizedBox(
                height: 10.0,
              ),
            Row ( children: [
              DropdownButton(
                  value: type,
                  items: [
                    DropdownMenuItem(
                      child: Text("Personal"),
                      value: LifeEvent.typePersonal,
                    ),
                    DropdownMenuItem(
                      child: Text("Purchase"),
                      value: LifeEvent.typePurchase,
                    ),
                    DropdownMenuItem(
                      child: Text("Birth"),
                      value: LifeEvent.typeBday,
                    ),
                    DropdownMenuItem(
                      child: Text("Death"),
                      value: LifeEvent.typeDeath,
                    ),
                    DropdownMenuItem(
                      child: Text("Work"),
                      value: LifeEvent.typeWork,
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      type = value;
                    });
                  }),
              ]
            ),
              ElevatedButton(
                child: Text('Save'),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        AppColours.appBackgroundColour)),
                onPressed: () {
                  // Validate returns true if the form is valid, otherwise false.
                  if (_formKey.currentState.validate()) {
                    int id;
                    if (widget.editMode) {
                      id = widget.lifeEvent.id;
                    }
                    LifeEvent le = LifeEvent(
                        id: id,
                        name: controllerName.text,
                        details: controllerDetails.text,
                        type: type,
                        theDay: selectedDate.toString());
                    _saveLifeEvent(le);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LifeEvents()));
                  }
                },
              ),
            ])));

    //_selectDate(context);

    return builtForm;
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1700),
      lastDate: DateTime(2025),
      initialEntryMode: DatePickerEntryMode.input,
      locale: Locale("en", "AU"),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<int> _saveLifeEvent(LifeEvent le) async {
    int id = -1;
    if (widget.editMode) {
      id = await dbHelper.update(le.toMap());
    } else {
      id = await dbHelper.insert(le.toMap());
    }
    return id;
  }
}
