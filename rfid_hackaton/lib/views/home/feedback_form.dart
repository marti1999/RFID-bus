import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rfid_hackaton/services/database.dart';


class feedbackForm extends StatelessWidget {
  feedbackForm({Key? key}) : super(key: key);

  // guarda l'estat actual del formulari
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
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
                      labelText:
                      'Your name',
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.max(30),
                    ]),
                  ),

                  FormBuilderTextField(
                    name: 'email',
                    decoration: const InputDecoration(
                      labelText:
                      'Your email',
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
                      labelText:
                          'Type your message here',
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

Future addFeedback(GlobalKey<FormBuilderState> formKey) async{
  // print(formKey.currentState.value);
  // TODO posar el user ID
  await DatabaseService(userID: '1').updateFeedback(formKey);
}
