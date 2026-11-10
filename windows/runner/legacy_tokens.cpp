#include "legacy_tokens.h"

#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <wincred.h>

#include <string>

namespace {

std::string ToUtf8(const std::wstring& w) {
  if (w.empty()) return std::string();
  int size = WideCharToMultiByte(CP_UTF8, 0, w.data(), static_cast<int>(w.size()),
                                 nullptr, 0, nullptr, nullptr);
  std::string out(size, '\0');
  WideCharToMultiByte(CP_UTF8, 0, w.data(), static_cast<int>(w.size()), out.data(),
                      size, nullptr, nullptr);
  return out;
}

std::wstring ToWide(const std::string& s) {
  if (s.empty()) return std::wstring();
  int size = MultiByteToWideChar(CP_UTF8, 0, s.data(), static_cast<int>(s.size()), nullptr, 0);
  std::wstring out(size, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, s.data(), static_cast<int>(s.size()), out.data(), size);
  return out;
}

flutter::EncodableList ListTokens(const std::string& service) {
  flutter::EncodableList entries;
  const std::wstring suffix = L"." + ToWide(service);
  const std::wstring filter = L"*" + suffix;
  DWORD count = 0;
  PCREDENTIALW* creds = nullptr;
  if (!CredEnumerateW(filter.c_str(), 0, &count, &creds)) return entries;
  for (DWORD i = 0; i < count; ++i) {
    const CREDENTIALW* c = creds[i];
    if (c->Type != CRED_TYPE_GENERIC || c->CredentialBlob == nullptr) continue;
    std::wstring target = c->TargetName ? c->TargetName : L"";
    std::wstring email = c->UserName ? c->UserName : L"";
    if (email.empty() && target.size() > suffix.size()) {
      email = target.substr(0, target.size() - suffix.size());
    }
    std::wstring token(reinterpret_cast<const wchar_t*>(c->CredentialBlob),
                       c->CredentialBlobSize / sizeof(wchar_t));
    if (email.empty() || token.empty()) continue;
    flutter::EncodableMap entry;
    entry[flutter::EncodableValue("email")] = flutter::EncodableValue(ToUtf8(email));
    entry[flutter::EncodableValue("token")] = flutter::EncodableValue(ToUtf8(token));
    entries.emplace_back(entry);
  }
  CredFree(creds);
  return entries;
}

}  // namespace

std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
RegisterLegacyTokens(flutter::BinaryMessenger* messenger) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, "exaton/legacy", &flutter::StandardMethodCodec::GetInstance());
  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() != "listTokens") {
          result->NotImplemented();
          return;
        }
        std::string service;
        if (const auto* args = std::get_if<flutter::EncodableMap>(call.arguments())) {
          auto it = args->find(flutter::EncodableValue("service"));
          if (it != args->end()) {
            if (const auto* s = std::get_if<std::string>(&it->second)) service = *s;
          }
        }
        if (service.empty()) {
          result->Error("bad_args", "service is required");
          return;
        }
        result->Success(flutter::EncodableValue(ListTokens(service)));
      });
  return channel;
}
