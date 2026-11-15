package com.example.nekaido_pre

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import android.os.Build
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.View
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val executor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hialyth/player_ui")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enterImmersive" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                            window.insetsController?.apply {
                                systemBarsBehavior = WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
                                hide(WindowInsets.Type.systemBars())
                            }
                        } else {
                            @Suppress("DEPRECATION")
                            window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_FULLSCREEN
                                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY)
                        }
                        result.success(null)
                    }
                    "exitImmersive" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                            window.insetsController?.show(WindowInsets.Type.systemBars())
                        } else {
                            @Suppress("DEPRECATION")
                            window.decorView.systemUiVisibility = 0
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hialyth/android_documents")
            .setMethodCallHandler { call, result ->
                val raw = call.argument<String>("uri")
                if (raw == null) {
                    result.error("invalid_uri", "Missing document URI", null)
                    return@setMethodCallHandler
                }
                if (call.method != "scan" && call.method != "exists") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                executor.execute {
                    try {
                        val uri = Uri.parse(raw)
                        val value: Any = if (call.method == "scan") scanTree(uri) else documentExists(uri)
                        Handler(Looper.getMainLooper()).post { result.success(value) }
                    } catch (e: Exception) {
                        Handler(Looper.getMainLooper()).post {
                            result.error("document_access", e.message, null)
                        }
                    }
                }
            }
    }

    private fun documentExists(uri: Uri): Boolean {
        contentResolver.query(uri, arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID), null, null, null)
            .use { cursor -> return cursor != null && cursor.moveToFirst() }
    }

    private fun scanTree(tree: Uri): List<Map<String, String>> {
        require(DocumentsContract.isTreeUri(tree)) { "Not a folder URI" }
        check(contentResolver.persistedUriPermissions.any { it.uri == tree && it.isReadPermission }) {
            "Persistent read access to the selected folder was not granted"
        }
        val result = mutableListOf<Map<String, String>>()
        val pending = ArrayDeque<String>()
        val seen = mutableSetOf<String>()
        pending.add(DocumentsContract.getTreeDocumentId(tree))
        val columns = arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME, DocumentsContract.Document.COLUMN_MIME_TYPE)
        while (pending.isNotEmpty()) {
            val parent = pending.removeFirst()
            if (!seen.add(parent)) continue
            val children = DocumentsContract.buildChildDocumentsUriUsingTree(tree, parent)
            val cursor = contentResolver.query(children, columns, null, null, null)
                ?: throw IllegalStateException("Unable to read selected folder")
            cursor.use {
                while (it.moveToNext()) {
                    val id = it.getString(0) ?: throw IllegalStateException("Missing document ID")
                    val name = it.getString(1) ?: throw IllegalStateException("Missing document name")
                    val mime = it.getString(2)
                    if (mime == DocumentsContract.Document.MIME_TYPE_DIR) {
                        pending.add(id)
                    } else if (name.substringAfterLast('.', "").lowercase() in setOf("mkv", "mp4", "avi")) {
                        result.add(mapOf("name" to name, "uri" to
                            DocumentsContract.buildDocumentUriUsingTree(tree, id).toString()))
                    }
                }
            }
        }
        return result
    }
}
