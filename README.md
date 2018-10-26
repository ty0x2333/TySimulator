<p align="center" >
  <img src="https://github.com/luckytianyiyan/TySimulator/raw/master/resources/tysimulator-logo.png" alt="TySimulator" title="TySimulator">
</p>

[![Build Status](https://travis-ci.org/luckytianyiyan/TySimulator.svg?branch=master)](https://travis-ci.org/luckytianyiyan/TySimulator)
[![codecov](https://codecov.io/gh/luckytianyiyan/TySimulator/branch/master/graph/badge.svg?token=m2rZatAaPl)](https://codecov.io/gh/luckytianyiyan/TySimulator)
[![codebeat badge](https://codebeat.co/badges/dd4cde17-107b-465e-a439-3e74def90795)](https://codebeat.co/projects/github-com-luckytianyiyan-tysimulator-master)
[![GitHub release](https://img.shields.io/github/release/luckytianyiyan/TySimulator.svg)]()
[![Swift Version](https://img.shields.io/badge/swift-4.2-orange.svg)]()

---

Website: [https://tysimulator.com](https://tysimulator.com)

Features
===
- Quick access to app's **Documents** directory
- Quick access to simulator's **Media** directory
- Manipulating current running or specified simulator
- Customized command
- Global hotkey
- Recent apps

Prerequisites
===
- macOS 10.11 or later
- XCode 7 or later

Installation
===
Install TySimulator from Website
[https://tysimulator.com](https://tysimulator.com)

or via [homebrew cask](https://github.com/caskroom/homebrew-cask)

```shell
$ brew update
$ brew cask install tysimulator
```

Building
===

Requirements
---
- XCode 10.0 or later
- [CocoaPods](https://github.com/CocoaPods/CocoaPods)
- [Carthage](https://github.com/Carthage/Carthage)

Optionals
---
- [xcpretty](https://github.com/supermarin/xcpretty) 0.2.8 or later

Instructions
---
```shell
$ git clone https://github.com/luckytianyiyan/TySimulator.git
$ cd TySimulator
$ make bootstrap
$ make build
```

Inspiration and UX Reference
---
TySimulator is inspired by [Simulator](https://github.com/hyperoslo/Simulator), [SimPholders](https://simpholders.com), [macdown](https://github.com/MacDownApp/macdown), but with an independent legal copyright. If you don't like the implementation, please consider [Simulator](https://github.com/hyperoslo/Simulator), [SimPholders](https://simpholders.com).

License
===

**TySimulator** is available under the MIT license. See the LICENSE file for more info.
