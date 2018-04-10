//
//  MGThreadUtils.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

public class MGThreadUtils {

    private init() {}

    //主線程 - 同步(卡住當前線程)
    public static func inMain(handler: () -> Void) {
        if Thread.isMainThread {
            handler()
        } else {
            DispatchQueue.main.sync {
                handler()
            }
        }
    }

    //主線程 - 延遲
    public static func inMain(delay: TimeInterval, handler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            handler()
        }
    }

    //主線程 - 異步
    public static func inMainAsync(handler: @escaping () -> Void) {
        DispatchQueue.main.async {
            handler()
        }
    }

    //子線程 - 同步(卡住當前線程) - 若當前為子線程則不創建
    //當目前為主線程時只能異步, 但能使用 信標(DispatchSemaphore) 達成目的
    public static func inSub(handler: @escaping () -> Void) {
        if Thread.isMainThread {

            let semaphore = DispatchSemaphore(value: 0) //使用信標, 等到 handler 執行完畢才發送信標, 藉此達到同步

            DispatchQueue.global().async {
                handler()
                semaphore.signal()
            }

            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        } else {
            handler()
        }
    }

    //子線程 - 延遲
    public static func inSub(delay: TimeInterval, handler: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            handler()
        }
    }

    //子線程 - 異步
    public static func inSubAsync(handler: @escaping () -> Void) {
        DispatchQueue.global().async {
            handler()
        }
    }


    //子線程 - 多任務同步串連
    //total: 任務串連數量
    //number: 第幾個任務(從 0 開始)
    public static func inSubMulti(total: Int , handler: @escaping (_ number: Int) -> Void) {

        if Thread.isMainThread {

            inSub {
                inSubMulti(total: total, handler: handler)
            }

        } else {

            //使用信標, 等到 handler 執行完畢才發送信標, 藉此達到同步
            //初始值 為信標量, 當等於
            // let semaphore = DispatchSemaphore(value: 0) 創建信標, 並且給予信標量 0
            // _ = semaphore.wait(timeout: DispatchTime.distantFuture) 信標量會減1, 若減1之後信標量小於0, 則會一直等待直到 信標量大於0
            // 可以設置等待時間 timeout, .distantFuture 為永久等待
            // semaphore.signal() 信標量 +1
            //            let semaphore = DispatchSemaphore(value: 0)

            //2017.09.18 - 發現 DispatchGroup 也可以做等待的動作, 所以不需用到 DispatchSemaphore 信標控制等待了

            let globalQueue = DispatchQueue.global()

            // 創建一個隊列
            let group = DispatchGroup()

            print("多隊列同步執行: \(total)")
            for i in 0..<total {
                globalQueue.async(group: group, execute: {
                    print("多隊列同步 number = \(i)")
                    handler(i)
                })
            }

            // group内的任务完成后,执行此方法
            group.notify(queue: globalQueue, execute: {
                print("全部隊列執行完畢")
                //                semaphore.signal()
            })

            group.wait()
            //            _ = semaphore.wait(timeout: DispatchTime.distantFuture)


        }

    }





}
