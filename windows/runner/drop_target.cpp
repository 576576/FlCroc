#include "drop_target.h"

#include <flutter/standard_method_codec.h>

#include <iostream>

namespace {

// Must match Dart's _DropChannel in lib/widgets/file_drop_target.dart.
constexpr char kChannelName[] = "fl_croc/drop";
constexpr char kMethodEntered[] = "entered";
constexpr char kMethodUpdated[] = "updated";
constexpr char kMethodExited[] = "exited";
constexpr char kMethodDropped[] = "dropped";
constexpr char kFieldX[] = "x";
constexpr char kFieldY[] = "y";
constexpr char kFieldPaths[] = "paths";

std::string Utf16ToUtf8(const std::wstring& text) {
  if (text.empty()) {
    return {};
  }
  const auto length = static_cast<int>(text.size());
  const int size = ::WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS,
                                        text.data(), length, nullptr, 0, nullptr,
                                        nullptr);
  if (size <= 0) {
    return {};
  }
  std::string converted(static_cast<size_t>(size), '\0');
  ::WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, text.data(), length,
                        converted.data(), size, nullptr, nullptr);
  return converted;
}

// Reads CF_HDROP, the shell's file list. A drop that carries something else
// (text, a bitmap) yields an empty list and is ignored.
std::vector<std::string> ReadPaths(IDataObject* data) {
  std::vector<std::string> paths;
  if (data == nullptr) {
    return paths;
  }

  FORMATETC format = {CF_HDROP, nullptr, DVASPECT_CONTENT, -1, TYMED_HGLOBAL};
  STGMEDIUM medium = {};
  if (data->GetData(&format, &medium) != S_OK) {
    return paths;
  }

  auto drop = static_cast<HDROP>(::GlobalLock(medium.hGlobal));
  if (drop != nullptr) {
    const UINT count = ::DragQueryFileW(drop, 0xFFFFFFFF, nullptr, 0);
    for (UINT i = 0; i < count; i++) {
      const UINT length = ::DragQueryFileW(drop, i, nullptr, 0);
      // +1 for the terminator the API writes; resize strips it again so the
      // converted path does not carry a trailing NUL.
      std::wstring path(static_cast<size_t>(length) + 1, L'\0');
      ::DragQueryFileW(drop, i, path.data(), length + 1);
      path.resize(length);
      paths.push_back(Utf16ToUtf8(path));
    }
    ::GlobalUnlock(medium.hGlobal);
  }
  ::ReleaseStgMedium(&medium);
  return paths;
}

bool CarriesFiles(IDataObject* data) {
  if (data == nullptr) {
    return false;
  }
  FORMATETC format = {CF_HDROP, nullptr, DVASPECT_CONTENT, -1, TYMED_HGLOBAL};
  return data->QueryGetData(&format) == S_OK;
}

}  // namespace

DropTarget::DropTarget(HWND view, flutter::BinaryMessenger* messenger)
    : view_(view),
      channel_(std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          messenger, kChannelName, &flutter::StandardMethodCodec::GetInstance())) {
  registered_ = SUCCEEDED(::RegisterDragDrop(view_, this));
  if (!registered_) {
    // The window then never reports a drag at all, so say why rather than
    // leaving it looking like the UI simply ignores drops.
    std::cout << "drop target: RegisterDragDrop failed, file drops are disabled "
              << "(is OLE initialised on this thread?)" << std::endl;
  }
}

DropTarget::~DropTarget() {
  // Must happen while the view still exists: after this returns, OLE has
  // stopped calling into this object.
  if (registered_) {
    ::RevokeDragDrop(view_);
    registered_ = false;
  }
}

HRESULT DropTarget::DragEnter(IDataObject* data, DWORD key_state, POINTL point,
                              DWORD* effect) {
  drop_effect_ = CarriesFiles(data) ? DROPEFFECT_COPY : DROPEFFECT_NONE;
  if (effect != nullptr) {
    *effect = drop_effect_;
  }
  if (drop_effect_ != DROPEFFECT_NONE) {
    SendPosition(kMethodEntered, point);
  }
  return S_OK;
}

HRESULT DropTarget::DragOver(DWORD key_state, POINTL point, DWORD* effect) {
  if (effect != nullptr) {
    *effect = drop_effect_;
  }
  if (drop_effect_ != DROPEFFECT_NONE) {
    SendPosition(kMethodUpdated, point);
  }
  return S_OK;
}

HRESULT DropTarget::DragLeave() {
  drop_effect_ = DROPEFFECT_NONE;
  if (channel_) {
    channel_->InvokeMethod(kMethodExited, nullptr);
  }
  return S_OK;
}

HRESULT DropTarget::Drop(IDataObject* data, DWORD key_state, POINTL point,
                         DWORD* effect) {
  drop_effect_ = DROPEFFECT_NONE;
  if (effect != nullptr) {
    *effect = DROPEFFECT_COPY;
  }
  SendDrop(point, ReadPaths(data));
  return S_OK;
}

HRESULT DropTarget::QueryInterface(REFIID iid, void** object) {
  if (object == nullptr) {
    return E_POINTER;
  }
  if (iid == IID_IUnknown || iid == IID_IDropTarget) {
    *object = static_cast<IDropTarget*>(this);
    AddRef();
    return S_OK;
  }
  *object = nullptr;
  return E_NOINTERFACE;
}

ULONG DropTarget::AddRef() { return static_cast<ULONG>(++ref_count_); }

ULONG DropTarget::Release() {
  if (ref_count_ > 0) {
    ref_count_--;
  }
  return static_cast<ULONG>(ref_count_);
}

void DropTarget::SendPosition(const char* method, POINTL point) {
  if (!channel_) {
    return;
  }
  POINT client = {point.x, point.y};
  ::ScreenToClient(view_, &client);
  channel_->InvokeMethod(
      method, std::make_unique<flutter::EncodableValue>(flutter::EncodableList{
                  flutter::EncodableValue(static_cast<double>(client.x)),
                  flutter::EncodableValue(static_cast<double>(client.y))}));
}

void DropTarget::SendDrop(POINTL point, std::vector<std::string> paths) {
  if (!channel_) {
    return;
  }
  POINT client = {point.x, point.y};
  ::ScreenToClient(view_, &client);

  flutter::EncodableList list;
  list.reserve(paths.size());
  for (const std::string& path : paths) {
    list.emplace_back(path);
  }

  channel_->InvokeMethod(
      kMethodDropped,
      std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
          {flutter::EncodableValue(kFieldX),
           flutter::EncodableValue(static_cast<double>(client.x))},
          {flutter::EncodableValue(kFieldY),
           flutter::EncodableValue(static_cast<double>(client.y))},
          {flutter::EncodableValue(kFieldPaths), flutter::EncodableValue(list)}}));
}
