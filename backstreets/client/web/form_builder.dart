/// Contains the [FormBuilder> class.
library form_builder;

import 'dart:html';

import 'main.dart';

/// The type of all validators.
typedef ValidatorType = String Function(String name, Map<String, String>, String);

/// A validator which will complain if [value] is empty.
String notEmptyValidator(String name, Map<String, String> values, String value) {
  if (value.isEmpty) {
    return 'You must provide a $name.';
  }
  return null;
}

/// An element within a [FormBuilder] instance.
class FormBuilderElement {
  FormBuilderElement(this.name, this.label, this.element, this.validator);

  /// The name of this element.
  final String name;

  /// The label of this element.
  String label;

  /// The element to render.
  final InputElementBase element;

  /// A function which will be passed [element.value] when [FormBuilder.validate]() is called.
  ///
  /// If it returns true, then validation is assumed to have passed.
  ValidatorType validator;
}

/// A class for building html [FormElement]s.
class FormBuilder {
  /// Create with a title and a callback.
  FormBuilder(
    this.title, this.done, {
      this.subtitle, this.autofocus = true, this.submitLabel = 'Submit',
      this.cancellable = true, this.cancelLabel = 'Cancel'
    }
  );

  /// The title of this form.
  ///
  /// The title will be shown in a [HeadingElement.h1] element.
  final String title;

  /// The subtitle of this form.
  ///
  /// If present, the subtitle will be shown in a [HeadingElement.h2] element.
  final String subtitle;

  /// The callback to be called when the form is submitted.
  final void Function(Map<String, String>) done;

  /// If true, automatically focus the first element of [form], when calling [render].
  bool autofocus;

  /// The label of the submit button.
  String submitLabel;

  /// If true, it will be possible to cancel this form.
  bool cancellable;

  /// The label for the cancel button which will be present on this form, if [cancellable] is true.
  String cancelLabel;

  /// All the [FormBuilderElement] instances contained by this form.
  List<FormBuilderElement> elements = <FormBuilderElement>[];

  /// The form element of this builder.
  FormElement form;

  /// Add an element to this builder.
  FormBuilderElement addElement(
    String name, {
      InputElementBase element, String label, ValidatorType validator
    }
  ) {
    element ??= TextInputElement();
    validator ??= (String name, Map<String, String> values, String value) => null;
    elements.add(FormBuilderElement(name, label, element, validator));
    return elements.last;
  }

  /// Build the [FormElement] to use in [render].
  ///
  /// The resulting form can be accessed with the [form] member.
  void buildFormElement() {
    form = FormElement();
    final HeadingElement h1 = HeadingElement.h1();
    h1.innerText = title;
    form.append(h1);
    if (subtitle != null) {
      final HeadingElement h2 = HeadingElement.h2();
      h2.innerText = subtitle;
      form.append(h2);
    }
    if (cancellable) {
      final ParagraphElement cancelParagraph = ParagraphElement();
      final ButtonElement cancelButton = ButtonElement();
      cancelButton.innerText = cancelLabel;
      cancelParagraph.append(cancelButton);
      form.append(cancelParagraph);
      cancelButton.onClick.listen((MouseEvent e) {
        destroy();
      });
    }
    for (final FormBuilderElement e in elements) {
      final ParagraphElement p = ParagraphElement();
      final LabelElement label = LabelElement();
      if (e.label == null) {
        // Next line copied and modified from from https://www.codevscolor.com/dart-capitalize-first-character-string/
        label.innerText = e.name[0].toUpperCase() + e.name.substring(1);
      } else {
        label.innerText = e.label;
      }
      label.append(e.element);
      p.append(label);
      form.append(p);
    }
    final ParagraphElement submitParagraph = ParagraphElement();
    final SubmitButtonInputElement submitButton = SubmitButtonInputElement();
    submitButton.innerText = submitLabel;
    submitParagraph.append(submitButton);
    form.append(submitParagraph);
    form.onSubmit.listen((Event e) {
      e.preventDefault();
      if (validate()) {
        final Map<String, String> data = <String, String>{};
        for (final FormBuilderElement e in elements) {
          data[e.name] = e.element.value;
        }
        destroy();
        done(data);
      }
    });
  }

  /// Remove the [form] element from the DOM, unhide and give focus to [keyboardArea].
  void destroy() {
    keyboardArea.hidden = false;
    currentFormBuilder = null;
    form.remove();
    keyboardArea.focus();
  }

  /// Validate the form, return true if successful, false otherwise.
  bool validate() {
    final Map<String, String> values = <String, String>{};
    for (final FormBuilderElement e in elements) {
      final String result = e.validator(e.name, values, e.element.value);
      if (result != null) {
        messageArea.innerText = result;
        e.element.focus();
        return false;
      }
      values[e.name] = e.element.value;
    }
    return true;
  }

  /// Render the form, and add it to the document.
  ///
  /// If you want to add the form to the document yourself, you can use the [buildFormElement] method.
  void render({bool override = true}) {
    if (currentFormBuilder == null || override) {
      if (currentFormBuilder != null) {
        currentFormBuilder.form.remove();
      }
      currentFormBuilder = this;
      keyboardArea.hidden = true;
      buildFormElement();
      document.body.append(form);
      if (autofocus && elements.isNotEmpty) {
        elements[0].element.focus();
      }
      form.focus();
    }
  }
}
