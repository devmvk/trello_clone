import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/src/material/debug.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/material_localizations.dart';
import 'package:trello_app/constants.dart';
import 'package:trello_app/task_model.dart';

typedef CardReorderCallback = void Function(int oldIndex, int newIndex, List<TaskModel> tasks);

class TaskCardContainer extends StatefulWidget {

  /// Creates a reorderable list.
  TaskCardContainer({
    this.id,
    this.header,
    @required this.children,
    @required this.onReorder,
    this.padding,
    @required this.tasks,
    Key key
  }) : assert(onReorder != null),
       assert(children != null),
       assert(
         children.every((Widget w) => w.key != null),
         'All children of this widget must have a key.',
       ),
       super(key:key);

  final List<TaskModel> tasks;

  final int id;

  /// A non-reorderable header widget to show before the list.
  ///
  /// If null, no header will appear before the list.
  final Widget header;

  /// The widgets to display.
  final List<Widget> children;

  /// The amount of space by which to inset the [children].
  final EdgeInsets padding;

  /// Called when a list child is dropped into a new position to shuffle the
  /// underlying list.
  ///
  /// This [ReorderableListView] calls [onReorder] after a list child is dropped
  /// into a new position.
  final CardReorderCallback onReorder;

  @override
  _TaskCardContainerState createState() => _TaskCardContainerState();
}

// This top-level state manages an Overlay that contains the list and
// also any Draggables it creates.
//
// _ReorderableListContent manages the list itself and reorder operations.
//
// The Overlay doesn't properly keep state by building new overlay entries,
// and so we cache a single OverlayEntry for use as the list layer.
// That overlay entry then builds a _ReorderableListContent which may
// insert Draggables into the Overlay above itself.
class _TaskCardContainerState extends State<TaskCardContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _TaskContainerContent(
          header: widget.header,
          children: widget.children,
          onReorder: widget.onReorder,
          padding: widget.padding,
          tasks: widget.tasks,
      );
  }
}

// This widget is responsible for the inside of the Overlay in the
// ReorderableListView.
class _TaskContainerContent extends StatefulWidget {
  const _TaskContainerContent({
    @required this.header,
    @required this.children,
    @required this.padding,
    @required this.onReorder,
    @required this.tasks
  });

  final Widget header;
  final List<Widget> children;
  final EdgeInsets padding;
  final CardReorderCallback onReorder;
  final List<TaskModel> tasks;
  
  @override
  _TaskContainerContentState createState() => _TaskContainerContentState();
}

class _TaskContainerContentState extends State<_TaskContainerContent> with TickerProviderStateMixin<_TaskContainerContent> {

  // The extent along the [widget.scrollDirection] axis to allow a child to
  // drop into when the user reorders list children.
  //
  // This value is used when the extents haven't yet been calculated from
  // the currently dragging widget, such as when it first builds.
  static const double _defaultDropAreaExtent = 100.0;

  // The additional margin to place around a computed drop area.
  static const double _dropAreaMargin = 8.0;

  
  // How long an animation to scroll to an off-screen element in the
  // list takes.
  static const Duration _scrollAnimationDuration = Duration(milliseconds: 200);

  // Controls scrolls and measures scroll progress.
  ScrollController _scrollController;


  // The member of widget.children currently being dragged.
  //
  // Null if no drag is underway.
  Key _dragging;

  // The last computed size of the feedback widget being dragged.
  Size _draggingFeedbackSize;

  // The location that the dragging widget occupied before it started to drag.
  int _dragStartIndex = 0;

  // The index that the dragging widget most recently left.
  // This is used to show an animation of the widget's position.
  int _ghostIndex = 0;

  // The index that the dragging widget currently occupies.
  int _currentIndex = 0;

  // The widget to move the dragging widget too after the current index.
  int _nextIndex = 0;

  // Whether or not we are currently scrolling this view to show a widget.
  bool _scrolling = false;

  double get _dropAreaExtent {
    if (_draggingFeedbackSize == null) {
      return _defaultDropAreaExtent;
    }
    return _draggingFeedbackSize.height + _dropAreaMargin;
  }

  @override
  void initState() {
    super.initState();
    entranceController.addStatusListener(_onEntranceStatusChanged);
    _scrollController = ScrollController();
    //taskCardContainerController.addListener();
  }

  void _onEntranceStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _requestAnimationToNextIndex();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Animates the droppable space from _currentIndex to _nextIndex.
  void _requestAnimationToNextIndex() {
    if (entranceController.isCompleted) {
      _ghostIndex = _currentIndex;
      if (_nextIndex == _currentIndex) {
        return;
      }
      _currentIndex = _nextIndex;
      ghostController.reverse(from: 1.0);
      entranceController.forward(from: 0.0);
    }
  }

  // Requests animation to the latest next index if it changes during an animation.
  

  void viewTaskContainerOnScreen(BuildContext context){
    final RenderObject contextObject = context.findRenderObject();
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(contextObject);
    viewport.showOnScreen(
      curve: Curves.easeInOut,
      descendant: contextObject,
      duration: Duration(milliseconds: 500)
    );

    // final double horizontalScrollOffSet = taskCardContainerController.offset;
    
    // final double leftOffset = max(
    //   taskCardContainerController.position.maxScrollExtent,
    //   viewport.getOffsetToReveal(contextObject, 0.0).offset - 8.0,
    // );
    // final double rightOffset = min(
    //   taskCardContainerController.position.maxScrollExtent,
    //   viewport.getOffsetToReveal(contextObject, 1.0).offset + 8.0,
    // );

    // final bool horizontalOnScreen = horizontalScrollOffSet <= leftOffset && horizontalScrollOffSet >= rightOffset;
    // if(!horizontalOnScreen){
    //   _scrolling = true;
    //   taskCardContainerController.position.animateTo(
    //     horizontalScrollOffSet < rightOffset ? rightOffset : leftOffset,
    //     duration: Duration(milliseconds: 700),
    //     curve: Curves.easeInOut,
    //   ).then((void value) {
    //     setState(() {
    //       _scrolling = false;
    //     });
    //   });
    // }
  
  }

  // Scrolls to a target context if that context is not on the screen.
  void _scrollTo(BuildContext context) {
    viewTaskContainerOnScreen(taskContainerContext);
    if (_scrolling)
      return;
    final RenderObject contextObject = context.findRenderObject();
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(contextObject);
    assert(viewport != null);
    // If and only if the current scroll offset falls in-between the offsets
    // necessary to reveal the selected context at the top or bottom of the
    // screen, then it is already on-screen.
    final double margin = _dropAreaExtent;
    final double scrollOffset = _scrollController.offset;
    final double topOffset = max(
      _scrollController.position.minScrollExtent,
      viewport.getOffsetToReveal(contextObject, 0.0).offset - margin,
    );
    final double bottomOffset = min(
      _scrollController.position.maxScrollExtent,
      viewport.getOffsetToReveal(contextObject, 1.0).offset + margin,
    );
    
    final bool verticalOnScreen = scrollOffset <= topOffset && scrollOffset >= bottomOffset;
    
    // If the context is off screen, then we request a scroll to make it visible.
    if (!verticalOnScreen) {
      _scrolling = true;
      _scrollController.position.animateTo(
        scrollOffset < bottomOffset ? bottomOffset : topOffset,
        duration: _scrollAnimationDuration,
        curve: Curves.easeInOut,
      ).then((void value) {
        setState(() {
          _scrolling = false;
        });
      });
    } 
  }

  // Wraps children in Row or Column, so that the children flow in
  // the widget's scrollDirection.
  Widget _buildContainerForScrollDirection({ List<Widget> children }) {
    return Column(children: children);
  }

  // Wraps one of the widget's children in a DragTarget and Draggable.
  // Handles up the logic for dragging and reordering items in the list.
  Widget _wrap(Widget toWrap, int index, BoxConstraints constraints) {
    assert(toWrap.key != null);
    final GlobalObjectKey keyIndexGlobalKey = GlobalObjectKey(toWrap.key);
    // We pass the toWrapWithGlobalKey into the Draggable so that when a list
    // item gets dragged, the accessibility framework can preserve the selected
    // state of the dragging item.
    
    // Starts dragging toWrap.
    void onDragStarted() {
      setState(() {
        _dragging = toWrap.key;
        _dragStartIndex = index;
        _ghostIndex = index;
        _currentIndex = index;
        entranceController.value = 1.0;
        _draggingFeedbackSize = keyIndexGlobalKey.currentContext.size;
      });
    }

    // Places the value from startIndex one space before the element at endIndex.
    void reorder(int startIndex, int endIndex) {
      setState(() {
        if (startIndex != endIndex)
          widget.onReorder(startIndex, endIndex, widget.tasks);
        // Animates leftover space in the drop area closed.
        // TODO(djshuckerow): bring the animation in line with the Material
        // specifications.
        ghostController.reverse(from: 0.1);
        entranceController.reverse(from: 0.1);
        _dragging = null;
      });
    }

    // Drops toWrap into the last position it was hovering over.
    void onDragEnded() {
      reorder(_dragStartIndex, _currentIndex);
    }

    Widget wrapWithSemantics() {
      // First, determine which semantics actions apply.
      final Map<CustomSemanticsAction, VoidCallback> semanticsActions = <CustomSemanticsAction, VoidCallback>{};

      // Create the appropriate semantics actions.
      void moveToStart() => reorder(index, 0);
      void moveToEnd() => reorder(index, widget.children.length);
      void moveBefore() => reorder(index, index - 1);
      // To move after, we go to index+2 because we are moving it to the space
      // before index+2, which is after the space at index+1.
      void moveAfter() => reorder(index, index + 2);

      final MaterialLocalizations localizations = MaterialLocalizations.of(context);

      // If the item can move to before its current position in the list.
      if (index > 0) {
        semanticsActions[CustomSemanticsAction(label: localizations.reorderItemToStart)] = moveToStart;
        String reorderItemBefore = localizations.reorderItemUp;
        // reorderItemBefore = Directionality.of(context) == TextDirection.ltr
        //       ? localizations.reorderItemLeft
        //       : localizations.reorderItemRight;
        semanticsActions[CustomSemanticsAction(label: reorderItemBefore)] = moveBefore;
      }

      // If the item can move to after its current position in the list.
      if (index < widget.children.length - 1) {
        String reorderItemAfter = localizations.reorderItemDown;
        reorderItemAfter = Directionality.of(context) == TextDirection.ltr
              ? localizations.reorderItemRight
              : localizations.reorderItemLeft;
        semanticsActions[CustomSemanticsAction(label: reorderItemAfter)] = moveAfter;
        semanticsActions[CustomSemanticsAction(label: localizations.reorderItemToEnd)] = moveToEnd;
      }

      // We pass toWrap with a GlobalKey into the Draggable so that when a list
      // item gets dragged, the accessibility framework can preserve the selected
      // state of the dragging item.
      //
      // We also apply the relevant custom accessibility actions for moving the item
      // up, down, to the start, and to the end of the list.
      return KeyedSubtree(
        key: keyIndexGlobalKey,
        child: MergeSemantics(
          child: Semantics(
            customSemanticsActions: semanticsActions,
            child: toWrap,
          ),
        ),
      );
    }

    Widget buildDragTarget(BuildContext context, List<Key> acceptedCandidates, List<dynamic> rejectedCandidates) {
      final Widget toWrapWithSemantics = wrapWithSemantics();
      // We build the draggable inside of a layout builder so that we can
      // constrain the size of the feedback dragging widget.
      Widget child = LongPressDraggable<Key>(
        maxSimultaneousDrags: 1,
        data: toWrap.key,
        ignoringFeedbackSemantics: false,
        feedback: Container(
          alignment: Alignment.topLeft,
          // These constraints will limit the cross axis of the drawn widget.
          constraints: constraints,
          child: Material(
            elevation: 6.0,
            child: toWrapWithSemantics,
          ),
        ),
        child: _dragging == toWrap.key ? const SizedBox() : toWrapWithSemantics,
        childWhenDragging: const SizedBox(),
        dragAnchor: DragAnchor.child,
        onDragStarted: onDragStarted,
        // When the drag ends inside a DragTarget widget, the drag
        // succeeds, and we reorder the widget into position appropriately.
        onDragCompleted: onDragEnded,
        // When the drag does not end inside a DragTarget widget, the
        // drag fails, but we still reorder the widget to the last position it
        // had been dragged to.
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          onDragEnded();
        },
      );

      // The target for dropping at the end of the list doesn't need to be
      // draggable.
      if (index >= widget.children.length) {
        child = toWrap;
      }

      // Determine the size of the drop area to show under the dragging widget.
      Widget spacing = SizedBox(height: _dropAreaExtent);

      // We open up a space under where the dragging widget currently is to
      // show it can be dropped.
      if (_currentIndex == index) {
        return _buildContainerForScrollDirection(children: <Widget>[
          SizeTransition(
            sizeFactor: entranceController,
            axis: Axis.vertical,
            child: spacing,
          ),
          child,
        ]);
      }
      // We close up the space under where the dragging widget previously was
      // with the ghostController animation.
      if (_ghostIndex == index) {
        return _buildContainerForScrollDirection(children: <Widget>[
          SizeTransition(
            sizeFactor: ghostController,
            axis: Axis.vertical,
            child: spacing,
          ),
          child,
        ]);
      }
      return child;
    }

    // We wrap the drag target in a Builder so that we can scroll to its specific context.
    return Builder(builder: (BuildContext context) {
      return DragTarget<Key>(
        builder: buildDragTarget,
        onWillAccept: (Key toAccept) {
          setState(() {
            _nextIndex = index;
            _requestAnimationToNextIndex();
          });
          _scrollTo(context);
          // If the target is not the original starting point, then we will accept the drop.
          return _dragging == toAccept && toAccept != toWrap.key;
        },
        onAccept: (Key accepted) { },
        onLeave: (Key leaving) { },
      );
    }); 
  }

  @override
  Widget build(BuildContext context) {
    taskContainerContext = context;
    assert(debugCheckHasMaterialLocalizations(context));
    // We use the layout builder to constrain the cross-axis size of dragging child widgets.
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final List<Widget> wrappedChildren = <Widget>[];
      for (int i = 0; i < widget.children.length; i += 1) {
        wrappedChildren.add(_wrap(widget.children[i], i, constraints));
      }
      const Key endWidgetKey = Key('DraggableList - End Widget');
      Widget finalDropArea = SizedBox(
            key: endWidgetKey,
            height: _defaultDropAreaExtent,
            width: constraints.maxWidth,
          );
      
      wrappedChildren.add(_wrap(
          finalDropArea,
          widget.children.length,
          constraints),
        );
      return Column(
        children: <Widget>[
          widget.header,
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: _buildContainerForScrollDirection(children: wrappedChildren),
              padding: widget.padding,
              controller: _scrollController,
            ),
          )
        ],
      );
    });
  }
}
