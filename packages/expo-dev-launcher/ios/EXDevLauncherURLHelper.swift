// Copyright 2015-present 650 Industries. All rights reserved.

import Foundation
import EXDevMenu

@objc
public class EXDevLauncherUrl: NSObject {
  @objc
  public var url: URL

  @objc
  public var queryParams: [String: String]

  @objc
  public init(_ url: URL) {
    self.queryParams = EXDevLauncherURLHelper.getQueryParamsForUrl(url)
    self.url = url

    if EXDevLauncherURLHelper.isDevLauncherURL(url) {
      let expoUrl = EXDevLauncherURLHelper.getExpoUrl(url)
      if let urlParam = expoUrl {
        if let urlFromParam = URL.init(string: urlParam) {
          self.url = EXDevLauncherURLHelper.replaceEXPScheme(urlFromParam, to: "http")
        }
      }
    } else {
      self.url = EXDevLauncherURLHelper.replaceEXPScheme(self.url, to: "http")
    }

    super.init()
  }
}

@objc
public class EXDevLauncherURLHelper: NSObject {
  @objc
  public static func isDevLauncherURL(_ url: URL?) -> Bool {
    return url?.host == "expo-development-client"
  }

  @objc
  public static func hasUrlQueryParam(_ url: URL) -> Bool {
    var hasUrlQueryParam = false

    let components = URLComponents.init(url: url, resolvingAgainstBaseURL: false)

    if ((components?.queryItems?.contains(where: {
      $0.name == "url" && $0.value != nil
    })) ?? false) {
      hasUrlQueryParam = true
    }

    return hasUrlQueryParam
  }

  @objc
  public static func disableOnboardingPopupIfNeeded(_ url: URL) {
    let components = URLComponents.init(url: url, resolvingAgainstBaseURL: false)

    if ((components?.queryItems?.contains(where: {
      $0.name == "disableOnboarding" && ($0.value ?? "") == "1"
    })) ?? false) {
      DevMenuPreferences.isOnboardingFinished = true
    }
  }

  @objc
  public static func replaceEXPScheme(_ url: URL, to scheme: String) -> URL {
    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    if components?.scheme == "exp" {
      components?.scheme = scheme
    }
    return components?.url ?? url
  }

  @objc
  public static func getExpoUrl(_ url: URL) -> String? {
    let input = url.absoluteString
    let regex = try! NSRegularExpression(pattern: "\\?url=(.*)")
    let range = NSRange(location: 0, length: input.utf16.count)
    guard let match = regex.firstMatch(in: input, options: [], range: range) else { return nil }
    return (input as NSString).substring(with: match.range(at:1))
  }

  @objc
  public static func getQueryParamsForUrl(_ url: URL) -> [String: String] {
    let components = URLComponents.init(url: url, resolvingAgainstBaseURL: false)
    var dict: [String: String] = [:]

    for parameter in components?.queryItems ?? [] {
      dict[parameter.name] = parameter.value?.removingPercentEncoding ?? ""
    }

    return dict
  }
}
