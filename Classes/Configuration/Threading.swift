//
//  Threading.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 11/6/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

func performOnMainThread(_ tasks: @escaping ()->()) {
    DispatchQueue.main.async {
        tasks()
    }
}

func performOnMainThreadAfter(seconds: Int, tasks:@escaping ()->()) {
    let deadline = DispatchTime.now() + Double(Int64(Double(seconds) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: deadline) { 
        tasks()
    }
}

func performOnBackgroundThread(_ tasks:@escaping ()->()) {
    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async { 
        tasks()
    }
}

func performOnMainThread(deadLine: DispatchTime, tasks:@escaping voidBlock) {
    DispatchQueue.main.asyncAfter(deadline: deadLine) {
        tasks()
    }
}
