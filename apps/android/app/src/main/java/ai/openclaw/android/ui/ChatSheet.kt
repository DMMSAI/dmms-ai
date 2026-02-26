package ai.dryadsai.android.ui

import androidx.compose.runtime.Composable
import ai.dryadsai.android.MainViewModel
import ai.dryadsai.android.ui.chat.ChatSheetContent

@Composable
fun ChatSheet(viewModel: MainViewModel) {
  ChatSheetContent(viewModel = viewModel)
}
