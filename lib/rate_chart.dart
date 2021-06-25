import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Rate {
  final double value;
  final DateTime time;

  Rate(this.value, this.time);
}

class RateChart extends StatefulWidget {
  final List<Rate> rates;

  RateChart(this.rates);

  @override
  _RateChartState createState() => _RateChartState();
}

const WeekDays = ["", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

class _RateChartState extends State<RateChart> {
  double _min, _max;
  List<double> _Y;
  List<String> _X;
  @override
  void initState() {
    super.initState();
    var min = double.maxFinite;
    var max = -double.maxFinite;
    widget.rates.forEach((element) {
      min = min > element.value ? element.value : min;
      max = max < element.value ? element.value : max;
      _Y = widget.rates.map((element) => element.value).toList();
      _X = widget.rates.map((element) => "${element.time.weekday}").toList();
    });

    setState(() {
      _min = min;
      _max = max;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(
        child: Container(),
        painter: ChartPainter(),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2.0, size.height / 2.0);
    final r = 50.0;
    final paint = Paint()..color = Colors.black;
    canvas.drawCircle(c, r, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
