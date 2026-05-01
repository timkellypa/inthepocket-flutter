import 'dart:convert';
import 'dart:io' as io show Directory, File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:path/path.dart' as path;

const QuillSimpleToolbarConfig standardToolbarConfig = QuillSimpleToolbarConfig(
  multiRowsDisplay: false,
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
  showIndent: true,
  showLink: false,
  showUndo: true,
  showRedo: true,
  showDirection: false,
  showSearchButton: false,
  showSubscript: false,
  showSuperscript: false,
);

/// Gets a standared editor focus node that will automatically scroll to the bottom of the editor
/// when it gains focus.
/// @param editorScrollContainerKey An optional key for the scroll container of the editor.  If provided,
/// the focus node will scroll this container to the bottom when it gains focus.  If not provided, it will
/// not scroll at all.
FocusNode getStandardEditorFocusNode(GlobalKey? editorScrollContainerKey,
    ScrollController? outerScrollController) {
  final FocusNode node = FocusNode();
  node.addListener(() {
    if (!node.hasFocus) {
      return;
    }

    int attemptsWithoutInset = 0;
    int attemptsWithInset = 0;
    const int maxAttemptsWithNoInset = 8;
    bool offsetShrinking = false;

    // As long as there's an inset, try this for a while.
    // Refocusing off another textfield will shrink and then grow the offset.
    const int maxAttemptsWithInset = 50;
    double previousInset = 0;

    void scrollNow() {
      final BuildContext? context = editorScrollContainerKey != null
          ? editorScrollContainerKey.currentContext
          : null;

      final RenderBox? box = context?.findRenderObject() as RenderBox?;
      if (box == null || context == null || outerScrollController == null) {
        return;
      }
      final double screenHeight = MediaQuery.of(context).size.height;
      final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      final double bottomY =
          box.localToGlobal(Offset.zero).dy + box.size.height;

      final double visibleBottom = screenHeight - keyboardHeight;

      final double overlap = bottomY - visibleBottom;

      if (overlap > 0) {
        // Ensure editor is still focused before scrolling
        if (!node.hasFocus) {
          return;
        }
        outerScrollController.animateTo(
          outerScrollController.offset + overlap + 20,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }

    void tryScroll() {
      final BuildContext? context = editorScrollContainerKey != null
          ? editorScrollContainerKey.currentContext
          : null;
      if (context == null || outerScrollController == null) {
        return;
      }
      final double inset = MediaQuery.of(context).viewInsets.bottom;
      final bool hasScroll = outerScrollController.hasClients &&
          outerScrollController.position.maxScrollExtent > 0;

      // Detect when inset settles (same number two frames in a row, but not while shrinking),
      // and scroll. Avoids scrolling in the middle of the keyboard animation.
      if (hasScroll && (inset > 0) && !offsetShrinking) {
        attemptsWithInset++;
        if (inset != previousInset &&
            attemptsWithInset <= maxAttemptsWithInset) {
          offsetShrinking = inset < previousInset;
          previousInset = inset;
          WidgetsBinding.instance.addPostFrameCallback((_) => tryScroll());
          return;
        }
        scrollNow();
        return;
      }

      if (attemptsWithoutInset < maxAttemptsWithNoInset) {
        attemptsWithoutInset++;
        WidgetsBinding.instance.addPostFrameCallback((_) => tryScroll());
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => tryScroll());
  });
  return node;
}

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
