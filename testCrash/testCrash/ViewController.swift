//
//  ViewController.swift
//  testCrash
//
//  Created by Jacob Jiang on 2/23/18.
//  Copyright © 2018 Jacob Jiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        let b = NSArray()
//        let d = b.object(at: 10)
        
        let b = [1,2,3]
        let d = b[5]
        
//        let d = TestCrash()
//        d.cppTest()
        
        
//        let d : String? = nil
//        let c = d!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

