



import 'package:flutter/material.dart';

class NoData extends StatefulWidget {
  final Color backgroundColor;
  final String text;
  final void Function() onPressed;
  const NoData({Key? key, required this.backgroundColor, required this.text, required this.onPressed}) : super(key: key);

  @override
  _NoDataState createState() => _NoDataState();
}

class _NoDataState extends State<NoData> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Text(widget.text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16),)
            ),
            ElevatedButton(
                child: const Text('Retry', style: TextStyle(fontSize: 16),),
                onPressed: widget.onPressed,
            )
          ],
        ),
      ),
    );
  }
}
