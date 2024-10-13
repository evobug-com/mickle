#include "flutter_window.h"

#include <optional>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <memory>

#include "audio_manager.h"
#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  // Audio Manager
    auto audio_manager_channel =
    std::make_shared<flutter::MethodChannel<>>(
        flutter_controller_->engine()->messenger(), "evobug.mickle/audio_manager",
        &flutter::StandardMethodCodec::GetInstance());

  audio_manager_channel->SetMethodCallHandler(
    [audio_manager_channel](const flutter::MethodCall<>& call, std::unique_ptr<flutter::MethodResult<>> result)
    {
        if(const auto& method_name = call.method_name(); method_name == "getInputDevices")
        {
            // Get the list of input devices
           flutter::EncodableList devices = AudioManager::getInputDevices();
           // Check if the list is not empty or if an error occurred
           if (!devices.empty()) {
               // Return the list of input devices
               result->Success(devices);
           } else {
               // Handle error if devices list is empty
               result->Error("UNAVAILABLE", "No input devices found.");
           }
        } else if (method_name == "getOutputDevices")
        {
            // Get the list of output devices
            flutter::EncodableList devices = AudioManager::getOutputDevices();
            // Check if the list is not empty or if an error occurred
            if (!devices.empty()) {
                // Return the list of output devices
                result->Success(devices);
            } else {
                // Handle error if devices list is empty
                result->Error("UNAVAILABLE", "No output devices found.");
            }
        } else if (method_name == "startCaptureStream")
        {
            const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
            if(!arguments)
            {
                result->Error("INVALID_ARGUMENTS", "No arguments provided.");
                return;
            }

            auto deviceId_it = arguments->find(flutter::EncodableValue("deviceId"));
            if (deviceId_it != arguments->end()) {
              const std::string deviceId = std::get<std::string>(deviceId_it->second);
              AudioManager::startCaptureStream(deviceId, audio_manager_channel);
              result->Success(flutter::EncodableValue(true));
            } else {
              result->Error("InvalidArguments", "Device ID not provided");
            }
        } else if (method_name == "stopCaptureStream")
        {
            const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
            if(!arguments)
            {
                result->Error("INVALID_ARGUMENTS", "No arguments provided.");
                return;
            }

            auto deviceId_it = arguments->find(flutter::EncodableValue("deviceId"));
            if (deviceId_it != arguments->end()) {
              const std::string deviceId = std::get<std::string>(deviceId_it->second);
              AudioManager::stopCaptureStream(deviceId);
              result->Success();
            } else {
              result->Error("InvalidArguments", "Device ID not provided");
            }
        } else if (method_name == "stopAllCaptureStreams")
        {
            // Stop all capture streams
            AudioManager::stopAllCaptureStreams();
            result->Success();
        }
        else
        {
            result->NotImplemented();
        }
    }
  );

  // Audio Manager END
  
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
