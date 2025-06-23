//
//  SampleDataManager.swift
//  QuoteHub
//
//  Created by 이융의 on 6/23/25.
//

import SwiftUI

// MARK: - 샘플 데이터 매니저

class SampleDataManager {
    
    // MARK: - 데이터 구조체
    
    struct SampleThemeData {
        let name: String
        let description: String?
        let imageName: String?
    }
    
    struct SampleBookStoryData {
        let bookId: String
        let quotes: [Quote]
        let content: String?
        let keywords: [String]?
        let imageNames: [String]?
    }
    
    // MARK: - 샘플 데이터 제공
    
    func getSampleThemeData() -> SampleThemeData? {
        return loadSampleThemeFromJSON()
    }
    
    func getSampleBookStoriesData() -> [SampleBookStoryData] {
        return loadSampleDataFromJSON() ?? []
    }
}

// MARK: - JSON 형태로 관리하고 싶은 경우

extension SampleDataManager {
    
    // JSON 파일에서 로드하는 방법
    private func loadSampleDataFromJSON() -> [SampleBookStoryData]? {
        guard let path = Bundle.main.path(forResource: "SampleData", ofType: "json"),
              let data = NSData(contentsOfFile: path) else {
            print("❌ SampleData.json 파일을 찾을 수 없습니다.")
            return nil
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String: Any]
            let bookStoriesArray = jsonObject?["bookStories"] as? [[String: Any]]
            return parseSampleDataFromJSON(bookStoriesArray)
        } catch {
            print("❌ JSON 파싱 오류: \(error)")
            return nil
        }
    }
    
    private func loadSampleThemeFromJSON() -> SampleThemeData? {
        guard let path = Bundle.main.path(forResource: "SampleData", ofType: "json"),
              let data = NSData(contentsOfFile: path) else {
            print("❌ SampleData.json 파일을 찾을 수 없습니다.")
            return nil
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String: Any]
            let themeJson = jsonObject?["theme"] as? [String: Any]
            return parseSampleThemeFromJSON(themeJson)
        } catch {
            print("❌ JSON 파싱 오류: \(error)")
            return nil
        }
    }
    
    private func parseSampleThemeFromJSON(_ themeJson: [String: Any]?) -> SampleThemeData? {
        guard let themeJson = themeJson,
              let name = themeJson["name"] as? String else {
            return nil
        }
        
        let description = themeJson["description"] as? String
        let imageName = themeJson["imageName"] as? String
        
        return SampleThemeData(
            name: name,
            description: description,
            imageName: imageName
        )
    }
    
    private func parseSampleDataFromJSON(_ jsonArray: [[String: Any]]?) -> [SampleBookStoryData] {
        guard let jsonArray = jsonArray else { return [] }
        
        var bookStories: [SampleBookStoryData] = []
        
        for json in jsonArray {
            guard let bookId = json["bookId"] as? String,
                  let quotesArray = json["quotes"] as? [[String: Any]] else {
                continue
            }
            
            let quotes = quotesArray.compactMap { quoteJson -> Quote? in
                guard let text = quoteJson["quote"] as? String else { return nil }
                let page = quoteJson["page"] as? Int
                return Quote(quote: text, page: page)
            }
            
            let content = json["content"] as? String
            let keywords = json["keywords"] as? [String]
            let imageNames = json["imageNames"] as? [String]
            
            let bookStory = SampleBookStoryData(
                bookId: bookId,
                quotes: quotes,
                content: content,
                keywords: keywords,
                imageNames: imageNames
            )
            
            bookStories.append(bookStory)
        }
        
        return bookStories
    }
}
