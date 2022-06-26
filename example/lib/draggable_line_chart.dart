import 'package:example/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/chart/line_chart.dart';
import 'package:flutter_chart/chart/common/base_layout_config.dart';
import 'package:flutter_chart/chart/common/chart_gesture_view.dart';
import 'package:flutter_chart/chart/impl/line/line_canvas_impl.dart';
import 'package:flutter_chart/chart/impl/line/line_layout_impl.dart';
import 'package:flutter_chart/chart/model/chart_data_model.dart';
import 'package:intl/intl.dart';

/// 拖拽&长按 的 Charts,横坐标依据数据长度而定。
/// 适合排列场景：07-1 、07-02、07-03、07-04...
/// 即：每个x轴刻度间的距离相同，x轴刻度之间只允许绘制一个点。
class DraggableLineChart extends StatefulWidget {
  const DraggableLineChart({Key? key}) : super(key: key);

  @override
  State<DraggableLineChart> createState() => _DraggableLineChartState();
}

class _DraggableLineChartState extends State<DraggableLineChart> {
  static int hour(int hour) => 1655913600 + 3600 * hour;

  /// 数据源
  final data = [
    ChartDataModel(xAxis: hour(7), yAxis: 8),
    ChartDataModel(xAxis: hour(8), yAxis: 8),
    ChartDataModel(xAxis: hour(9), yAxis: 8),
    ChartDataModel(xAxis: hour(10), yAxis: 12),
    ChartDataModel(xAxis: hour(11), yAxis: 8),
    ChartDataModel(xAxis: hour(12), yAxis: 24),
    ChartDataModel(xAxis: hour(13), yAxis: 33),
    ChartDataModel(xAxis: hour(14), yAxis: 16),
    ChartDataModel(xAxis: hour(15), yAxis: 14),
  ];

  Size? size;
  final margin = const EdgeInsets.symmetric(horizontal: 10);

  @override
  Widget build(BuildContext context) {
    var pixel = MediaQuery.of(context).size.width;
    size ??= Size(pixel, 264);
    return Container(
      width: double.infinity,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ChartGestureView<ChartDataModel>(
        initConfig: LineLayoutConfig(
          data: data,
          size: Size(pixel - margin.horizontal, 264),
          delegate: CommonLineAxisDelegate.copyWith(
            xAxisFormatter: _xAxisFormatter,
            yAxisFormatter: _yAxisFormatter,
            lineStyle: CommonLineAxisDelegate.lineStyle?.copyWith(
              color: Colors.green,
            ),
          ),
          popupSpec: CommonPopupSpec.copyWith(
            textFormatter: _textFormatter,
            // popupShouldDraw: _popupShouldShow,
            // bubbleShouldDraw: _popupBubbleShouldShow,
            lineStyle: CommonPopupSpec.lineStyle?.copyWith(
              color: Colors.lightGreen,
            ),
          ),
        ),
        builder: (_, newConfig) => CustomPaint(
          size: size!,
          painter: LineChart(
            data: data,
            contentCanvas: LineCanvasImpl(),
            layoutConfig: newConfig as BaseLayoutConfig<ChartDataModel>,
          ),
        ),
      ),
    );
  }

  /// 悬浮框内容
  InlineSpan _textFormatter(ChartDataModel data) {
    var xAxis = DateFormat('HH:mm')
        .format(DateTime.fromMillisecondsSinceEpoch(data.xAxis * 1000));

    /// 是否为异常数据
    var normalValue = 20;
    bool isException = data.yAxis > normalValue;
    Color color = isException ? Colors.red : Colors.black;
    return TextSpan(
      text: '$xAxis\n',
      style: const TextStyle(fontSize: 12, color: Colors.black),
      children: [
        TextSpan(
          text: isException ? '气温：大于' : '气温: ',
          style: TextStyle(fontSize: 12, color: color),
        ),
        TextSpan(
          text: isException ? normalValue.toString() : '${data.yAxis.toInt()}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextSpan(
          text: '°c',
          style: TextStyle(fontSize: 14, color: color),
        ),
      ],
    );
  }

  /// x轴坐标数据格式化
  String _xAxisFormatter(int index) {
    return DateFormat('HH:mm')
        .format(DateTime.fromMillisecondsSinceEpoch(data[index].xAxis * 1000));
  }

  /// y轴坐标数据格式化
  String _yAxisFormatter(num data, int index) {
    return data.toInt().toString();
  }
}
