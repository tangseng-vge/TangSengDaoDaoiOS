//
//  WKReactionManager.swift
//  WuKongAdvanced
//
//  Created by tt on 2022/6/27.
//

import Foundation
import WuKongBase

@objc public class WKReactionProvider:NSObject {
    
    @objc public static let shared = WKReactionProvider()
    
    @objc public func reactions() -> [ReactionContextItem] {
        // 回应表情
        var reactionItems:[ReactionContextItem] = []
       
        let reactionNames = ["like","bad","love","fire","celebrate","happy","haha","terrified","shit","vomit"]
        for reactionName in reactionNames {
            let reactionAppear =  WuKongReactionFile(name: reactionName, path: getReactionURL(filePath: "Other/reactions/"+reactionName+"_appear", tp: "lim"))
            
            reactionItems.append( ReactionContextItem.init(reaction: ReactionContextItem.Reaction.init(rawValue: reactionName), appearAnimation: reactionAppear, stillAnimation:  reactionAppear, listAnimation: reactionAppear, largeListAnimation: reactionAppear, applicationAnimation: reactionAppear, largeApplicationAnimation: reactionAppear))
        }
        return reactionItems
    }
    func getReactionURL(filePath:String,tp:String) -> String {
        
        let bundle = WKApp.shared().resourceBundle("WuKongAdvanced")
        return bundle.path(forResource: filePath, ofType: tp)!
    }
}
