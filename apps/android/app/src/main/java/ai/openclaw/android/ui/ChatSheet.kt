package ai.dmmsai.android.ui

import androidx.compose.runtime.Composable
import ai.dmmsai.android.MainViewModel
import ai.dmmsai.android.ui.chat.ChatSheetContent

@Composable
fun ChatSheet(viewModel: MainViewModel) {
  ChatSheetContent(viewModel = viewModel)
}
