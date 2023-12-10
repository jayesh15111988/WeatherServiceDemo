//
//  Style.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

/// A style framework to encode all the app styles. Includes color, images etc.
public final class Style {

    public static let shared = Style()

    private let bundle: Bundle

    private init() {
        self.bundle = Bundle(for: type(of: self))
    }

    public lazy var favoriteImage: UIImage = {
        return UIImage(named: "favorite")!
    }()

    public lazy var nonFavoriteImage: UIImage = {
        return UIImage(named: "nonfavorite")!
    }()

    public lazy var defaultTextColor: UIColor = {
        UIColor(named: "defaultTextColor", in: self.bundle, compatibleWith: nil)!
    }()

    public lazy var subtleTextColor: UIColor = {
        UIColor(named: "subtleTextColor", in: self.bundle, compatibleWith: nil)!
    }()

    public lazy var backgroundColor: UIColor = {
        UIColor(named: "backgroundColor", in: self.bundle, compatibleWith: nil)!
    }()

    public lazy var sectionHeaderBackgroundColor: UIColor = {
        UIColor(named: "sectionHeaderBackground", in: self.bundle, compatibleWith: nil)!
    }()
}

