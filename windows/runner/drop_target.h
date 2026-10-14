#ifndef RUNNER_DROP_TARGET_H_
#define RUNNER_DROP_TARGET_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <ole2.h>
#include <windows.h>

#include <memory>
#include <string>
#include <vector>

// Accepts files dropped from the shell onto the Flutter view and reports them to
// Dart over a method channel ("fl_croc/drop"): entered / updated / exited while
// the drag moves, and dropped with the file list.
//
// Only Windows implements this. The other desktop platforms have no drop target,
// so their UI falls back to the file picker.
//
// Positions travel as physical client pixels, matching what Dart's
// devicePixelRatio expects; the Dart side scales them and then decides which
// widget the cursor was over, because the target covers the whole view while
// several widgets may want the drop.
class DropTarget : public IDropTarget {
 public:
  DropTarget(HWND view, flutter::BinaryMessenger* messenger);
  // Not `override`: IUnknown has no virtual destructor, and this object is only
  // ever destroyed through the owning unique_ptr.
  ~DropTarget();

  DropTarget(const DropTarget&) = delete;
  DropTarget& operator=(const DropTarget&) = delete;

  // IDropTarget
  HRESULT STDMETHODCALLTYPE DragEnter(IDataObject* data, DWORD key_state,
                                      POINTL point, DWORD* effect) override;
  HRESULT STDMETHODCALLTYPE DragOver(DWORD key_state, POINTL point,
                                     DWORD* effect) override;
  HRESULT STDMETHODCALLTYPE DragLeave() override;
  HRESULT STDMETHODCALLTYPE Drop(IDataObject* data, DWORD key_state,
                                 POINTL point, DWORD* effect) override;

  // IUnknown
  //
  // The owning FlutterWindow controls the lifetime; Release never deletes,
  // because OLE can hold a reference across a drag while the unique_ptr that
  // created this object still owns it. RevokeDragDrop in the destructor is what
  // guarantees OLE has stopped calling in by then.
  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, void** object) override;
  ULONG STDMETHODCALLTYPE AddRef() override;
  ULONG STDMETHODCALLTYPE Release() override;

 private:
  void SendPosition(const char* method, POINTL point);
  void SendDrop(POINTL point, std::vector<std::string> paths);

  HWND view_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
  LONG ref_count_ = 0;
  bool registered_ = false;
  // Remembered from DragEnter so DragOver can keep answering without the
  // IDataObject, which it is not given.
  DWORD drop_effect_ = DROPEFFECT_NONE;
};

#endif  // RUNNER_DROP_TARGET_H_
