import 'package:animated_drag_gridview/animated_drag_gridview.dart';
import 'package:animated_drag_gridview/drag_gridview_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:vibration/vibration.dart';

class DragItem extends StatefulWidget {
  int index;
  int fixedNum;
  int crossAxisCount;
  double mainAxisSpacing;
  double crossAxisSpacing;

  bool isOpenDragAble;
  bool isActive;
  int animationDuration;
  int longPressDuration;

  Widget tRWidget;
  Widget itemChild;

  GestureCallback gestureCallback;

  DragItem({
    required this.index,
    required this.gestureCallback,
    required this.itemChild,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.crossAxisCount,
    required this.isOpenDragAble,
    required this.isActive,
    required this.fixedNum,
    required this.tRWidget,
    required this.animationDuration,
    required this.longPressDuration,
    Key? key,
  }) : super(key: key);

  @override
  State<DragItem> createState() => DragItemState();
}

class DragItemState extends State<DragItem> with TickerProviderStateMixin {
  bool _dragging = false; //是否在拖拽

  bool isLongPress = false; //长按控制

  int get index => widget.index;

  late DragGridViewMixin _listState;

  AnimationController? _offsetAnimation;

  late int currentIndex; //当前 index

  int newIndex = -1;

  Offset _startOffset = Offset.zero; //开始的偏移位置

  Offset _targetOffset = Offset.zero; //目标偏移位置

  bool isAnimateEnd = false; //用来判断拖拽结束时候 是否有动画

  bool isAnimate = false; //用来限制删除动画时，不能点击其他item

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
    _listState = DragGridViewMixin.of(context);
    _listState.dragItem(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _listState.dragItem(this);
  }

  //拖拽更新 int oldIndex, int newIndex
  void updateForGap(dragIndex, newIndex) {
    this.newIndex = newIndex;

    if (!mounted) return;

    if (_dragging) {
      return;
    }
    if (index < widget.fixedNum) return;

    int indexOffsetLeg = dragIndex - newIndex;

    for (int i = 0; i < indexOffsetLeg.abs(); i++) {
      if (indexOffsetLeg > 0) {
        ////当前item 左上移动
        if (newIndex + 1 * i == currentIndex) {
          _calOffsetLeftUp();
          break;
        }
      } else if (indexOffsetLeg < 0) {
        //当前item 右下移动
        if (newIndex - 1 * i == currentIndex) {
          _calOffsetRightBottom();
          break;
        }
      }
    }
  }

  //计算 item 向左上 要偏移的位置 然后开始动画
  _calOffsetLeftUp() async {
    RenderObject? renderObject = context.findRenderObject();

    var row = currentIndex % widget.crossAxisCount; //列数

    var itemWidth =
        (renderObject as RenderBox).size.width + widget.crossAxisSpacing;
    var itemHeight = 0.0;

    //判断列数是不是在最右边，最右边要向下做移动
    if (row == widget.crossAxisCount - 1) {
      itemWidth =
          -((renderObject as RenderBox).size.width + widget.crossAxisSpacing) *
              (widget.crossAxisCount - 1);
      itemHeight =
          (renderObject as RenderBox).size.height + widget.mainAxisSpacing;
    }
    _startOffset = _targetOffset;
    _targetOffset = Offset(itemWidth, itemHeight) + _targetOffset;
    startAnimate();

    await Future.delayed(const Duration(milliseconds: 50), () {
      currentIndex = currentIndex + 1;
    });
  }

  //计算 item 向右下上 要偏移的位置 然后开始动画
  _calOffsetRightBottom() async {
    if (!mounted) return;
    RenderObject? renderObject = context.findRenderObject();
    if (renderObject == null) {
      Offset.zero;
    }

    var row = currentIndex % widget.crossAxisCount; //列数

    var itemWidth =
        -((renderObject as RenderBox).size.width + widget.crossAxisSpacing);
    var itemHeight = 0.0;

    //判断列数是不是在最左边，最左边要向上做移动
    if (row == 0) {
      itemWidth =
          ((renderObject as RenderBox).size.width + widget.crossAxisSpacing) *
              (widget.crossAxisCount - 1);
      itemHeight =
          -((renderObject as RenderBox).size.height + widget.mainAxisSpacing);
    }
    _startOffset = _targetOffset;
    _targetOffset = Offset(itemWidth, itemHeight) + _targetOffset;
    startAnimate();

    await Future.delayed(const Duration(milliseconds: 50), () {
      currentIndex = currentIndex - 1;
    });
  }

  //开始动画
  startAnimate() {
    if (_offsetAnimation == null) {
      _offsetAnimation = AnimationController(vsync: this)
        ..duration = Duration(milliseconds: widget.animationDuration)
        ..addListener(rebuild)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _offsetAnimation?.dispose();
            _offsetAnimation = null;
          }
        })
        ..forward(from: 0.0);
    } else {
      _startOffset = offset;
      _offsetAnimation?.forward(from: 0.0);
    }
  }

  //item 偏移量
  Offset get offset {
    if (_offsetAnimation != null) {
      return Offset.lerp(
        _startOffset,
        _targetOffset,
        Curves.easeInOut.transform(_offsetAnimation!.value),
      )!;
    }
    return _targetOffset;
  }

  //删除item时其他 item的位移
  deleteItemOffset() {
    _calOffsetRightBottom();
  }

  isDelete(bool isAnimate) {
    this.isAnimate = isAnimate;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isOpenDragAble ? onTapDownEvent : null,
      onPanUpdate: widget.isOpenDragAble ? onPanUpdateEvent : null,
      onPanEnd: widget.isOpenDragAble ? onPanEndEvent : null,
      onTapUp: !isAnimate ? onTapUpEvent : null,
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    if (_dragging) {
      return SizedBox();
    }

    return Transform(
      transform: Matrix4.translationValues(offset.dx, offset.dy, 0),
      child: Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          Container(
            child: widget.itemChild,
          ),
          widget.isActive
              ? Positioned(
                  top: -2,
                  right: -2,
                  child: widget.tRWidget,
                )
              : SizedBox(),
        ],
      ),
    );
  }

  //按下事件
  onTapDownEvent(TapDownDetails e) async {
    if (isAnimate) return;
    isLongPress = true;

    await Future.delayed(Duration(milliseconds: widget.longPressDuration));
    if (isLongPress == true) {
      //震动
      Vibration.vibrate(duration: 15, amplitude: 100);
      if (widget.isActive) {
        _listState.dragStart(
          widget.index,
          context,
          e,
          widget.itemChild,
          widget.tRWidget,
          widget.crossAxisCount,
          widget.crossAxisSpacing,
          widget.mainAxisSpacing,
        );

        _dragging = true;

        rebuild();
      } else {
        widget.gestureCallback.onActive(true);
      }
    }
  }

  //拖动事件
  onPanUpdateEvent(e) {
    if (_dragging == true) {
      _listState.dragUpdate(e);
    }
  }

  //拖动结束事件
  onPanEndEvent(e) {
    _listState.dragCancel(currentIndex, newIndex);
  }

  //点击事件
  onTapUpEvent(e) async {
    isLongPress = false;

    if (isAnimate) return;

    if (_dragging) {
      _dragging = false;

      _listState.dragCancel(currentIndex, newIndex);

      rebuild();
    } else {
      if (widget.isActive) {
        //走删除

        _dragging = true;

        _listState.isDeleteAnimate(true);

        _listState.deleteItem(currentIndex, widget.fixedNum);

        rebuild();

        await Future.delayed(
            Duration(milliseconds: widget.animationDuration + 10), () {
          // 等待动画结束  删除回调 偷个懒 直接一个计时加10

          _listState.isDeleteAnimate(false);

          widget.gestureCallback.onTapDelete(currentIndex);
        });
      } else {
        //走点击
        widget.gestureCallback.onTapItem(currentIndex);
      }
    }
  }

  //拖拽结束回调
  onPanEndBack() {
    if (!_dragging) return;

    isLongPress = false;
    _dragging = false;
    setState(() {});

    if (newIndex == -1) return;
    widget.gestureCallback.onPanEnd(currentIndex, newIndex);

    newIndex = -1;
  }

  void rebuild() {
    if (mounted) {
      setState(() {});
    }
  }
}
