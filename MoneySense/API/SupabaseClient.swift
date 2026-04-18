//
//  SupabaseClient.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 17/4/26.
//

import Supabase
import Foundation

final class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        guard
            let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let url = URL(string: urlString),
            let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String
        else {
            fatalError("Missing Supabase configuration")
        }
        
        self.client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }
}
