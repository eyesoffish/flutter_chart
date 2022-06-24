import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/common/axis_delegate.dart';
import 'package:flutter_chart/chart/common/base_layout_config.dart';
import 'package:flutter_chart/chart/common/find.dart';
import 'package:flutter_chart/chart/common/gesture_delegate.dart';
import 'package:flutter_chart/chart/common/popup_spec.dart';
import 'package:flutter_chart/chart/model/chart_data_model.dart';
import 'package:intl/intl.dart';

/// line charts配置
class LineLayoutConfig extends BaseLayoutConfig<ChartDataModel> {
  LineLayoutConfig({
    required super.data,
    required super.size,
    super.axisCount,
    super.delegate,
    super.gestureDelegate,
    super.popupSpec,
    super.padding,
  });

  @override
  LineLayoutConfig copyWith({
    List<ChartDataModel>? data,
    int? axisCount,
    Size? size,
    AxisDelegate<ChartDataModel>? delegate,
    GestureDelegate? gestureDelegate,
    PopupSpec<ChartDataModel>? popupSpec,
    EdgeInsets? padding,
  }) {
    return LineLayoutConfig(
      data: data ?? this.data,
      size: size ?? this.size,
      axisCount: axisCount ?? this.axisCount,
      delegate: delegate ?? this.delegate,
      gestureDelegate: gestureDelegate ?? this.gestureDelegate,
      popupSpec: popupSpec ?? this.popupSpec,
      padding: padding ?? this.padding,
    );
  }

  /// 本组数据的最大值
  double? _maxValue;

  @override
  double get maxValue {
    _maxValue ??= getMaxValue(data);
    return _maxValue!;
  }

  @override
  double getMaxValue(List<ChartDataModel> data) {
    var value = 0.0;
    for (var model in data) {
      value = max(value, model.yAxis);
    }
    return value;
  }

  /// 获取y轴的数据值
  @override
  num yAxisValue(ChartDataModel data) => data.yAxis;

  /// 拖拽的最大宽度
  @override
  double? get draggableWidth => size.width - padding.horizontal;

  /// 获取x轴指定位置的值 07：00
  /// 优先级比[AxisDelegate.xAxisFormatter]高。
  @override
  String xAxisValue(int index) {
    var hour = index;
    var now = DateTime.now();
    var date = DateTime(now.year, now.month, now.day, hour);
    return DateFormat('HH:mm').format(date);
  }

  /// 根据手势触摸坐标查找指定数据点位
  @override
  ChartTargetFind<ChartDataModel>? findTarget(Offset offset) {
    ChartTargetFind<ChartDataModel>? find;
    // 横轴两点之间的距离
    var itemWidth = delegate?.domainPointSpacing ?? 0;
    // 当前拖拽的偏移量
    var dragX = (gestureDelegate?.offset ?? Offset.zero).dx;

    /// 1s时长对应的宽度，全程24小时，两个点之间的跨度为1小时。
    var dw = itemWidth / 3600; // 3600s为1小时

    for (var index = 0; index < data.length; index++) {
      var model = data[index];

      var date = DateTime.fromMillisecondsSinceEpoch(model.xAxis * 1000);
      var hour = date.hour;
      var minute = date.minute;
      var seconds = date.second + minute * 60 + hour * 3600;

      var curr = Offset(
        // bounds.left + dragX + itemWidth * index,
        bounds.left + dragX + dw * seconds,
        bounds.bottom - yAxisValue(model) / maxValue * bounds.height,
      );
      if ((curr - offset).dx.abs() < itemWidth / 2) {
        find = ChartTargetFind(model, curr);
        break;
      }
    }
    return find;
  }
}
