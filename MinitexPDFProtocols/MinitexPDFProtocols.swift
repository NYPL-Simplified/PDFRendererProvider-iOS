//
//  MinitexPDFProtocols.swift
//  MinitexPDFProtocols
//
//  Created by Vui Nguyen on 4/26/18.
//  Copyright © 2018 Minitex. All rights reserved.
//

import Foundation
import UIKit


/// A generic annotation in a PDF document.
@objc public protocol MinitexPDFAnnotation: class {
  /// An annotation must belong to one page of the PDF document.
  var page: MinitexPDFPage { get }

  /// Complex annotations may be fully described by something like JSON from a particular
  /// renderer. This allows easy access by the host to a version it can store or sync.
  ///
  /// - Returns: A data representation of the annotation, like from a JSON encoder.
  func toData() -> Data

  /// Conversely, an annotation should be able to be reconstructed from the serialized data.
  ///
  /// - Parameter data: The serialized data.
  /// - Returns: An instance of an annotation.
  static func fromData(_ data: Data) -> MinitexPDFAnnotation?
}

/// The View Controller for the PDF document.
@objc public protocol MinitexPDFViewController: class {
  /// The host can optionally set a delegate object to listen for certain events.
  var delegate: MinitexPDFViewControllerDelegate? { get set }

  /// Initialize a view controller with a particular PDF document.
  ///
  /// - Parameters:
  ///   - file: The local file directory of the PDF document.
  ///   - page: An optional page to navigate to when first opening.
  ///   - bookmarks: Any additional user-saved bookmarks.
  ///   - annotations: Any additional user-created generic annotations.
  init?(file: URL,
        openToPage page: MinitexPDFPage?,
        bookmarks: [MinitexPDFPage]?,
        annotations: [MinitexPDFAnnotation]?)
}

/// A page in a PDF document.
@objcMembers public class MinitexPDFPage : NSObject, Codable {
  /// A PDF document must have an unsigned integer represenation of its pages.
  let pageNumber: UInt

  init(pageNumber: UInt) {
    self.pageNumber = pageNumber
  }

  /// Complex annotations may be fully described by something like JSON from a particular
  /// renderer. This allows easy access by the host to a version it can store or sync.
  ///
  /// - Returns: A data representation of the annotation, like from a JSON encoder.
  public func toData() -> Data {
    return try! JSONEncoder().encode(self)
  }

  /// Conversely, an annotation should be able to be reconstructed from the serialized data.
  ///
  /// - Parameter data: The serialized data.
  /// - Returns: An instance of an annotation.
  public class func fromData(_ data: Data) -> MinitexPDFPage? {
    return try? JSONDecoder().decode(MinitexPDFPage.self, from: data)
  }
}

@objc public protocol MinitexPDFViewControllerDelegate: class {
  /// Called when a page of the PDF document becomes the new presented page
  /// visible on screen.
  ///
  /// - Parameter page: The page being presented on screen.
  func userDidNavigate(toPage page: MinitexPDFPage)
  /// Called when a user selects to create a bookmark for a specific page.
  ///
  /// - Parameter bookmark: The specific page the user has selected to save as a
  ///   bookmark.
  func userDidCreate(bookmark: MinitexPDFPage)
  /// Called when a user selects to delete a bookmark for a specific page.
  ///
  /// - Parameter bookmark: The specific page the user has selected to delete.
  func userDidDelete(bookmark: MinitexPDFPage)
  /// Called when a user selects to create a generic annotation for a specific page.
  ///
  /// - Parameter bookmark: The specific generic annotation the user has selected to save as a
  ///   bookmark.
  func userDidCreate(annotation: MinitexPDFAnnotation)
  /// Called when a user selects to delete a generic annotation for a specific page.
  ///
  /// - Parameter bookmark: The specific generic annotation the user has selected to delete.
  func userDidDelete(annotation: MinitexPDFAnnotation)
}

//MARK: -
//MARK: Factory Methods

@objcMembers public class MinitexPDFViewControllerFactory: NSObject {
  /// The API host must create a View Controller for the PDF from a static factory method.
  ///
  /// - Parameters:
  ///   - fileUrl: The local file directory of the PDF document.
  ///   - page: An optional page to navigate to when first opening.
  ///   - bookmarks: Any additional user-saved bookmarks.
  ///   - annotations: Any additional user-created generic annotations.
  /// - Returns: An instance of MinitexPDFViewController, or nil if something failed.
  public static func create(fileUrl: URL,
                            openToPage page: MinitexPDFPage?,
                            bookmarks: [MinitexPDFPage]?,
                            annotations: [MinitexPDFAnnotation]?) -> MinitexPDFViewController? {

    // PDF renderer using a PSPDFKit license.
    if let pdfViewControllerClass = NSClassFromString("PDF.PDFViewController") as? MinitexPDFViewController.Type {
      return pdfViewControllerClass.init(file: fileUrl, openToPage: page, bookmarks: bookmarks, annotations: annotations)
    } else {
      // PDF renderer using Apple's PDFKit.
      fatalError()  //placeholder
    }
  }
}
