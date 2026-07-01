package org.antaresnet.appgv

import io.flutter.embedding.android.FlutterFragmentActivity

// `local_auth` richiede una FragmentActivity per mostrare il prompt
// biometrico (BiometricPrompt), non la FlutterActivity di default.
class MainActivity : FlutterFragmentActivity()
