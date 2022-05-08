import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rfid_hackaton/services/database.dart';

import 'home_button.dart';

class feedbackForm extends StatefulWidget {
  const feedbackForm({Key? key}) : super(key: key);

  @override
  State<feedbackForm> createState() => _feedbackFormState();
}

class _feedbackFormState extends State<feedbackForm> {
  int _counter = 0;
  bool feedback_sent = false;
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    if (feedback_sent) {
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;
      return Scaffold(
          body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 170,
              padding: EdgeInsets.all(35),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                "assets/images/card.png",
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: screenHeight * 0.1),
            const Text(
              "Thank You!",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 36,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            const Text(
              "Feedback sent Successfully",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                fontSize: 17,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            const Text(
              "Cclick here to return to home page",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
            SizedBox(height: screenHeight * 0.06),
            Flexible(
              child: HomeButton(
                title: 'Home',
                onTap: () {
                  // TODO: preguntar al bruno com canviar de panatlla
                  print('clicat per tornar a Home');
                },
              ),
            ),
          ],
        ),
      ));
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Column(
          children: <Widget>[
            FormBuilder(
              key: formKey,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                    name: 'name',
                    decoration: const InputDecoration(
                      labelText: 'Your name',
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.max(30),
                    ]),
                  ),
                  FormBuilderTextField(
                    name: 'email',
                    decoration: const InputDecoration(
                      labelText: 'Your email',
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                      FormBuilderValidators.max(100),
                    ]),
                  ),
                  FormBuilderChoiceChip(
                    name: 'type',
                    autovalidateMode: AutovalidateMode.always,
                    alignment: WrapAlignment.spaceEvenly,
                    decoration: const InputDecoration(
                      labelText: 'Select an option',
                    ),
                    options: const [
                      FormBuilderFieldOption(
                          value: 'Question', child: Text('Question')),
                      FormBuilderFieldOption(
                          value: 'Issue', child: Text('Issue')),
                      FormBuilderFieldOption(
                          value: 'Suggestion', child: Text('Suggestion')),
                    ],
                  ),
                  FormBuilderTextField(
                    name: 'message',
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Type your message here',
                    ),
                    // valueTransformer: (text) => num.tryParse(text),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.max(200),
                    ]),
                    //keyboardType: TextInputType.number,
                  ),
                  FormBuilderCheckbox(
                    name: 'accept_terms',
                    initialValue: false,
                    title: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'I have read and agree to the ',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    validator: FormBuilderValidators.equal(
                      true,
                      errorText:
                          'You must accept terms and conditions to continue',
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: MaterialButton(
                    color: Theme.of(context).colorScheme.secondary,
                    child: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        print(formKey.currentState?.value);
                        addFeedback(formKey);
                        setState(() {
                          feedback_sent = true;
                        });

                      } else {
                        print("validation failed");
                      }
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: MaterialButton(
                    color: Theme.of(context).colorScheme.secondary,
                    child: const Text(
                      "Reset",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      formKey.currentState?.reset();
                    },
                  ),
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}

Future addFeedback(GlobalKey<FormBuilderState> formKey) async {
  // print(formKey.currentState.value);
  // TODO posar el user ID
  await DatabaseService(userID: '1').updateFeedback(formKey);
}
