//
//  File.swift
//  programmaticSwiftV1
//
//  Created by Christopher Guirguis on 12/21/16.
//  Copyright © 2016 Christopher Guirguis. All rights reserved.
//


import UIKit
class questionTableViewCell: UITableViewCell {
    //This variable will track whether or not this has been answered before
    
    
    var myLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        myLabel.backgroundColor = UIColor.clear
        self.contentView.addSubview(myLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        myLabel.frame = CGRect(x: 0, y: 0, width: 70, height: 30)
    }
}
