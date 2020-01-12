//
//  Reactive+SVProgressHUD.swift
//  AirQuality
//
//  Created by Richard Moult on 1/1/20.
//  Copyright © 2020 RichardMoult. All rights reserved.
//

import RxSwift
import RxCocoa
import SVProgressHUD

extension Reactive where Base: SVProgressHUD {

   public static var isAnimating: Binder<Bool> {
      // By default it binds elements on main scheduler.
      return Binder(UIApplication.shared) { _, isVisible in
         if isVisible {
            SVProgressHUD.show()
         } else {
            SVProgressHUD.dismiss()
         }
      }
   }
}
