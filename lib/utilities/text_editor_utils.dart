import 'dart:convert';
import 'dart:io' as io show Directory, File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:path/path.dart' as path;

const QuillSimpleToolbarConfig standardToolbarConfig = QuillSimpleToolbarConfig(
  multiRowsDisplay: true,
  showDividers: false,
  showFontFamily: false,
  showFontSize: true,
  showBoldButton: true,
  showItalicButton: true,
  showLineHeightButton: false,
  showStrikeThrough: false,
  showInlineCode: false,
  showColorButton: true,
  showBackgroundColorButton: true,
  showClearFormat: false,
  showAlignmentButtons: true,
  showHeaderStyle: false,
  showListNumbers: true,
  showListBullets: true,
  showListCheck: false,
  showCodeBlock: false,
  showQuote: false,
  showIndent: false,
  showLink: true,
  showUndo: true,
  showRedo: true,
  showDirection: false,
  showSearchButton: false,
  showSubscript: false,
  showSuperscript: false,
);

FocusNode getStandardEditorFocusNode() => FocusNode();
ScrollController getStandardEditorScrollController() => ScrollController();

final QuillEditorImageEmbedConfig standardImageEmbedConfig =
    QuillEditorImageEmbedConfig(
  imageProviderBuilder: (BuildContext context, String imageUrl) {
    // https://pub.dev/packages/flutter_quill_extensions#-image-assets
    if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    }
    return null;
  },
);

final QuillEditorVideoEmbedConfig standardVideoEmbedConfig =
    QuillEditorVideoEmbedConfig(
        customVideoBuilder: (String videoUrl, bool readOnly) {
  return null;
});

Future<String> downloadImageAsset(
    Uint8List imageBytes, String extension) async {
  final String newFileName =
      '$extension-file-${DateTime.now().toIso8601String()}.$extension';
  final String newPath = path.join(
    io.Directory.systemTemp.path,
    newFileName,
  );
  final io.File file = await io.File(
    newPath,
  ).writeAsBytes(imageBytes, flush: true);
  return file.path;
}

Set<String> getImagePathsInDocument(Document document) {
  final Set<String> usedPaths = <String>{};
  final Delta delta = document.toDelta();

  for (final Operation operation in delta.operations) {
    if (operation.isInsert && operation.data is Map) {
      final Map<String, dynamic>? data = operation.data as Map<String, dynamic>;
      if (data != null && data.containsKey('image')) {
        final String imagePath = data['image'] as String;
        usedPaths.add(imagePath);
      }
    }
  }

  return usedPaths;
}

/// Deletes images that were cached by the UI but are no longer used by the document after user
/// deletions, etc.
/// @param document The current document being edited, which may have had images removed by the user.
/// @param cachedImagePaths The set of image paths that have been cached by the UI during
/// editing.  Any paths in this set that are not found in the document will be deleted from the file
/// system.
/// @return A Future that completes when the cleanup process is finished.  The Future will complete
/// with a Set of the remaining cached image paths that are still in use by the document.
Future<Set<String>> cleanupOrphanedImagesFromDocument(
    Document document, Set<String> cachedImagePaths) async {
  final Set<String> usedPaths = getImagePathsInDocument(document);
  final Set<String> orphanedPaths = cachedImagePaths.difference(usedPaths);

  for (final String filePath in orphanedPaths) {
    try {
      final io.File file = io.File(filePath);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      // Log error but don't fail the save operation
      print('Error deleting orphaned image: $e');
    }
  }
  return usedPaths;
}

Document getQuillDocumentFromContent(String? content) {
  if (content == null || content.isEmpty) {
    return Document();
  }
  try {
    return Document.fromJson(jsonDecode(content));
  } catch (e) {
    // If content is not valid JSON, treat it as plain text
    return Document()..insert(0, content);
  }
}
