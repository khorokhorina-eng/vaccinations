// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VaccinationCalendar",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "VaccinationCalendar",
            targets: ["VaccinationCalendar"]),
    ],
    dependencies: [
        // В данном проекте внешние зависимости не используются
    ],
    targets: [
        .target(
            name: "VaccinationCalendar",
            dependencies: []),
        .testTarget(
            name: "VaccinationCalendarTests",
            dependencies: ["VaccinationCalendar"]),
    ]
)