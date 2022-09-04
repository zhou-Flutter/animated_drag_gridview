import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:animated_drag_gridview/drag_info.dart';
import 'package:animated_drag_gridview/drag_item.dart';
import 'package:flutter/foundation.dart';

mixin DragGridViewMixin<T extends StatefulWidget> on State<T> {
  static DragGridViewMixin of(BuildContext context) {
    return context.findAncestorStateOfType<DragGridViewMixin>()!;
  }

  final Map<int, DragItemState> __dragItems = <int, DragItemState>{};
  final Map<int, DragInfoState> __dragInfo = <int, DragInfoState>{};

  void dragItem(DragItemState item) {
    __dragItems[item.index] = item;
  }

  void dragInfo(DragInfoState item) {
    __dragInfo[0] = item;
  }

  Offset dragStartPos = Offset.zero; //开始拖拽时的 手指位置
  Offset dragInfoOffset = Offset.zero; //开始拖拽时 拖拽小组件的偏移量
  int dragIndex = -1;
  double itemWidth = 0;
  double itemHeight = 0;

  int crossAxisCount = 3;
  double mainAxisSpacing = 0;
  double crossAxisSpacing = 0;

  //拖拽开始
  void dragStart(
    int dragIndex,
    BuildContext context,
    TapDownDetails e,
    Widget itemChild,
    Widget tRWidget,
    int crossAxisCount,
    double mainAxisSpacing,
    double crossAxisSpacing,
  ) {
    dragStartPos = Offset(e.localPosition.dx, e.localPosition.dy);
    this.dragIndex = dragIndex;
    this.crossAxisCount = crossAxisCount;
    this.mainAxisSpacing = mainAxisSpacing;
    this.crossAxisSpacing = crossAxisSpacing;

    RenderObject? renderObject = context.findRenderObject();
    if (renderObject == null) {
      Offset.zero;
    }
    //  var cent = (renderObject as RenderBox).size.center(Offset.zero);
    itemWidth = (renderObject as RenderBox).size.width;
    itemHeight = (renderObject as RenderBox).size.height;

    dragInfoOffset = calOffset(dragIndex);

    //通知拖拽小部件
    __dragInfo[0]?.dragInfoStart(
      dragInfoOffset,
      itemChild,
      tRWidget,
      itemWidth,
      itemHeight,
    );
  }

  ///计算拖拽小组件的开始 偏移量
  Offset calOffset(index) {
    var row = index % crossAxisCount; //列数
    var col = (index / crossAxisCount).floor(); //行数
    var offsetX = row * itemWidth + mainAxisSpacing * row; //列坐标
    var offsetY = col * itemHeight + crossAxisSpacing * col; //行坐标
    return Offset(offsetX, offsetY);
  }

  //拖拽中
  void dragUpdate(DragUpdateDetails e) {
    Offset updateOffset = Offset(
        dragInfoOffset.dx + e.localPosition.dx - dragStartPos.dx,
        dragInfoOffset.dy + e.localPosition.dy - dragStartPos.dy);

    //通知小组件开始更新位置
    __dragInfo[0]?.dragInfoUpdate(updateOffset);

    _calcDragItemIsAnimate(updateOffset);
  }

  //拖拽取消
  void dragCancel(currentIndex, toIndex) {
    if (toIndex != -1) {
      dragInfoOffset = calOffset(toIndex);
    }

    __dragInfo[0]?.dragInfoCancel(currentIndex, toIndex, dragInfoOffset);

    dragInfoOffset = Offset(0.0, 0.0);
    dragStartPos = Offset(0.0, 0.0);
  }

  //拖拽取消回调
  void dragCancalBack() {
    for (var item in __dragItems.values) {
      item.onPanEndBack();
    }
  }

  //点击item 删除item
  void deleteItem(currentIndex, fixedNum) {
    for (int i = currentIndex + 1; i < __dragItems.length + fixedNum; i++) {
      __dragItems[i]?.deleteItemOffset();
    }
    __dragItems.clear();
  }

  void isDeleteAnimate(bool isAnimate) {
    for (var item in __dragItems.values) {
      item.isDelete(isAnimate);
    }
  }

  ///计算 DragItem 是否需要排序动画
  void _calcDragItemIsAnimate(Offset updateOffset) {
    for (var item in __dragItems.values) {
      var dragNewItemIndex = item.index;

      Offset otherItem = calOffset(dragNewItemIndex);

      var ah = sqrt(pow(updateOffset.dx - otherItem.dx, 2) +
          pow(updateOffset.dy - otherItem.dy, 2));

      if (ah < itemWidth / 2 && ah < itemHeight / 2) {
        if (dragNewItemIndex != dragIndex) {
          for (var itemf in __dragItems.values) {
            //dragNewItemIndex 移动到新的 item 的 index
            itemf.updateForGap(dragIndex, dragNewItemIndex);
          }
          dragIndex = dragNewItemIndex;
          break;
        }
      }
    }
  }
}
