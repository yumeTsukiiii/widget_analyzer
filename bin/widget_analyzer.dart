import 'dart:convert';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:widget_analyzer/widget_analyzer.dart' as widget_analyzer;

void main(List<String> arguments) async {
//   print('Hello world: ${widget_analyzer.calculate()}!');
//   // final result = parseFile(
//   //   path: 'E:\\dev_env\\flutter\\flutter\\packages\\flutter\\lib\\src\\material\\app_bar.dart',
//   //   featureSet: FeatureSet.latestLanguageVersion()
//   // );
//   final result = parseString(content: '''
//
// class B {
// }
//
// class A {
//   final int c;
//
//   A(int a, {int d = 0, required this.c, B b});
//   A.a(int a, int b, [int? d, int c = 0]);
//   factory A.create() {
//     return A(0);
//   }
//
// }
//   ''');
//   final unit = result.unit;
//   unit.visitChildren(WidgetVisitor());

// E:\\projects\\widget_analyzer\\lib\\widget_analyzer.dart
//E:\\projects\\compute-pc-config\\lib\\shinku_chat.dart
//E:\\dev_env\\flutter\\flutter\\packages\\flutter
  List<String> includedPaths = ['E:\\projects\\compute-pc-config'];
  AnalysisContextCollection collection = AnalysisContextCollection(includedPaths: includedPaths, excludedPaths: []);
  await analyzeSomeFiles(collection, includedPaths);

}

analyzeSomeFiles(
    AnalysisContextCollection collection, List<String> includedPaths) async {
  for (String path in includedPaths) {
    AnalysisContext context = collection.contextFor(path);
    final list = context.contextRoot.analyzedFiles().toList();
    await analyzeSingleFile(context, '$path\\lib\\shinku_chat.dart');
  }
}

extension IterableExt<T> on Iterable<T> {
  T? firstOrNull(bool Function(T t) test) {
    for (T t in this) {
      if (test(t)) {
        return t;
      }
    }
    return null;
  }
}

analyzeSingleFile(AnalysisContext context, String path) async {
  // See below.
  AnalysisSession session = context.currentSession;
  final start = DateTime.now().millisecondsSinceEpoch;
  final result = await session.getUnitElement(path);
  print('cost: ${DateTime.now().millisecondsSinceEpoch - start}');
  if (result is UnitElementResult) {
    CompilationUnitElement element = result.element;
    print(jsonEncode(listWidget(element.enclosingElement)));
    // final materialLibrary = element.enclosingElement.imports.firstOrNull(
    //   (element) => element.uri == 'package:flutter/material.dart',
    // )?.importedLibrary;
    // materialLibrary?.exportedLibraries.forEach((libraryElement) {
    //   final a = libraryElement.definingCompilationUnit.classes.where((classElement) => classElement.isAccessibleIn(element.enclosingElement));
    //   print(element);
    // });
  }
}

extension ClassElementExt on ClassElement {

  bool isType(String name) {
    return allSupertypes.any((superType) => superType.element.name == name);
  }

}

Map<String, dynamic> parseWidgetConstructorParam(ParameterElement widgetParameterElement) {
  final result = <String, dynamic>{};
  // result['param'] = widgetParameterElement;
  result['name'] = widgetParameterElement.name;
  result['strType'] = widgetParameterElement.type.getDisplayString(withNullability: true); // 用尾部判断是否为空
  result['isRequired'] = widgetParameterElement.isRequired;
  result['isOptional'] = widgetParameterElement.isOptional;
  result['kind'] = widgetParameterElement.isNamed ? 'NAMED' : 'POSITIONAL';
  return result;
}

Map<String, dynamic> parseWidgetConstructor(ConstructorElement widgetConstructorElement) {
  final result = <String, dynamic>{};
  result['name'] = widgetConstructorElement.name;
  result['parameters'] = widgetConstructorElement.parameters.map(parseWidgetConstructorParam).toList();
  return result;
}

Map<String, dynamic> parseWidgetElement(ClassElement widgetElement) {
  final result = <String, dynamic>{};
  result['name'] = widgetElement.name;
  // result['library'] = widgetElement.library;
  result['library'] = widgetElement.library.identifier;
  // result['constructors'] = widgetElement.constructors;
  result['constructors'] = widgetElement.constructors.map(parseWidgetConstructor).toList();
  return result;
}

List<Map<String, dynamic>> listWidget(LibraryElement library) {
  return library.exportNamespace.definedNames.values.whereType<ClassElement>().where(
    (classElement) => classElement.isType('Widget')
  ).map(parseWidgetElement).toList();
}

class WidgetVisitor extends GeneralizingAstVisitor<void> {

  final List<ClassDeclaration> classDeclarations = [];

  @override
  visitClassDeclaration(ClassDeclaration node) {
    if (!node.name.name.startsWith('_')) {
      classDeclarations.add(node);
    }
    return super.visitClassDeclaration(node);
  }

}

// class WidgetConstructorParameter {
//
//   String name;
//   String type;
//
//
//
// }
//
// class WidgetConstructor {
//
//   String? name;
//
//   bool get isNamed => name != null;
//
// }
//
// class WidgetDefine {
//
//   final String name;
//
//
// }