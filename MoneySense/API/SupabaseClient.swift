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
//        guard
//            let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
//            let url = URL(string: urlString),
//            let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String
//        else {
//            fatalError("Missing Supabase configuration")
//        }
        let url = URL(string: "https://ttfjygxmpszdjscyiowt.supabase.co")!
            let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0Zmp5Z3htcHN6ZGpzY3lpb3d0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwMDQwMjgsImV4cCI6MjA5MTU4MDAyOH0.6SCf4XJSACGAFyHojBh3UZEzUselbslQxy8yICvfTuk"
                    
        self.client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }
}
