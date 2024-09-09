import 'package:flutter/material.dart';


class InputIcon {
  late IconData icons;
  late VoidCallback? onPressed;
  late double? size;

  InputIcon({
    required this.icons,
    this.onPressed,
    this.size
  });
}


typedef CustomValidator = String? Function(String? value);
class CustomInput extends StatelessWidget {
  const CustomInput({
    super.key,
    this.controller,
    required this.size,
    required this.hint,
    this.inputType,
    this.title,
    this.icons,
    this.validator,
    this.disabled
  });

  final TextEditingController? controller;
  final double? size;
  final String? hint;
  final TextInputType? inputType;
  final String? title;
  final InputIcon? icons;
  final CustomValidator? validator;
  final bool? disabled;
  

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Builder(builder: (context) {
          if (title != null) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(title!, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
            );
          }

          return const Text('');
        }),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          // obscureText: isPassword == null ? false : obscureText,
          validator: validator,
          enabled: disabled == null ? true : !disabled!,
          style: TextStyle(fontSize: size),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hint,
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.only(left: 20.0, bottom: 10, top: 10),
            errorStyle: const TextStyle(
              color: Color.fromARGB(255, 160, 47, 47),
              fontSize: 10,
              fontWeight: FontWeight.w300
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF000000), width: 1.0)
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFC5C6CC), width: 1.0)
            ),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFC5C6CC), width: 1.0)
            ),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color.fromARGB(255, 160, 47, 47), width: 1.0)
            ),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color.fromARGB(255, 160, 47, 47), width: 1.0)
            ),
            suffixIcon: icons == null ? 
            null
            : InkWell(
              onTap: icons?.onPressed,
              child: Icon(
                icons?.icons,
                color: Colors.black,
                size: icons?.size
              )
            )
          ),
        )
      ],
    );
  }
}

typedef CustomCallback = void Function(DateTime? date);

class CustomDatePicker extends StatelessWidget {
  const CustomDatePicker({
    super.key,
    this.controller,
    this.title,
    this.size,
    required this.hint,
    required this.picked
  });


  final TextEditingController? controller;
  final CustomCallback picked;
  final String? title;
  final double? size;
  final String? hint;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? current = await showDatePicker(
      context: context,
      // barrierColor: Colors.white,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            hintColor: Colors.black,
            colorScheme: const ColorScheme.light(primary: Colors.black),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      }
    );

    picked(current);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Builder(builder: (context) {
          if (title != null) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(title!, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
            );
          }

          return const Text('');
        }),
        InkWell(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              style: TextStyle(fontSize: size),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: hint,
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.only(left: 20.0, bottom: 10, top: 10),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF000000), width: 1.0)
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFC5C6CC), width: 1.0)
                )
              ),
            ),
          )
        )
      ],
    );
  }
}



typedef CustomDropDownCallBack = void Function(String? value);

class CustomDropDown extends StatelessWidget {
  const CustomDropDown({
    super.key,
    required this.callback,
    required this.hint,
    required this.items,
    this.title,
    this.size,
    required this.value
  });

  final String hint;
  final double? size;
  final List<dynamic> items;
  final String? title;
  final String value;
  final CustomDropDownCallBack callback;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Builder(builder: (context) {
          if (title != null) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(title!, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
            );
          }

          return const Text('');
        }),
        DropdownButtonFormField<String>(
      // value: _selectedItem,
          style: TextStyle(fontSize: size, color: Colors.black),
          value: value,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.grey,
            ),
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.only(left: 20.0, bottom: 10, top: 10, right: 10),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF000000), width: 1.0)
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFC5C6CC), width: 1.0)
            )
          ),
          // items: <String>[...items]
          //     .map((String value) {
          //   return DropdownMenuItem<String>(
          //     value: value,
          //     child: Text(value),
          //   );
          // }).toList(),
          items: items.map<DropdownMenuItem<String>>((item) {
            return DropdownMenuItem<String>(
              value: item['seq'].toString(),
              child: Text(item['name']),
            );
          }).toList(),
          onChanged: (String? newValue) {
            callback(newValue);
          },
        )
      ],
    );
  }
}