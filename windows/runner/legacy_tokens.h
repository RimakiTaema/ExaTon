#ifndef RUNNER_LEGACY_TOKENS_H_
#define RUNNER_LEGACY_TOKENS_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>

#include <memory>

// Channel "exaton/legacy": lists tokens saved by ExaTon 1.5 (keyring crate)
// in Windows Credential Manager. Target names are "{email}.{service}" and
// the blob is UTF-16. Read only.
std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
RegisterLegacyTokens(flutter::BinaryMessenger* messenger);

#endif  // RUNNER_LEGACY_TOKENS_H_
