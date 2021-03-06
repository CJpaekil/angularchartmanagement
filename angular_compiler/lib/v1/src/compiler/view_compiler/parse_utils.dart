import '../expression_parser/ast.dart'
    show AST, ImplicitReceiver, MethodCall, PropertyRead;
import 'constants.dart';

enum HandlerType { simpleNoArgs, simpleOneArg, notSimple }

/// Classifies this event binding by it's form.
///
/// The simple form looks like
///
///     (event)="handler($event)"
///
/// or
///
///     (event)="handler()"
///
/// Since these types of handlers are so common, we can optimize the code
/// generated for them.
HandlerType handlerTypeFromExpression(AST handler) {
  var eventHandler = handler;
  if (eventHandler is! MethodCall) {
    return HandlerType.notSimple;
  }
  var call = eventHandler;
  if (call.receiver is! ImplicitReceiver || call.namedArgs.isNotEmpty) {
    return HandlerType.notSimple;
  }
  if (call.args.isEmpty) {
    return HandlerType.simpleNoArgs;
  }
  if (call.args.length != 1) {
    return HandlerType.notSimple;
  }
  var singleArg = call.args.single;
  if (singleArg is! PropertyRead) {
    return HandlerType.notSimple;
  }
  var property = singleArg;
  if (property.name == EventHandlerVars.event.name &&
      property.receiver is ImplicitReceiver) {
    return HandlerType.simpleOneArg;
  } else {
    return HandlerType.notSimple;
  }
}
