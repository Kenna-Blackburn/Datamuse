//
//  Datamuse.swift
//  Datamuse
//
//  Created by Kenna Blackburn on 5/20/26.
//

import Foundation

public final class Datamuse {
    public let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func words(_ parameters: [AnyParameter]) async throws -> [Result] {
        try await fetch("words", with: parameters)
    }
    
    public func suggestions(_ prefix: String, _ parameters: [AnyParameter] = []) async throws -> [Result] {
        precondition(parameters.allSatisfy(\.supportsSuggestions))
        return try await fetch("sug", with: [.init("s", value: prefix)] + parameters)
    }
    
    private func makeRequest(with parameters: [AnyParameter]) -> URLRequest {
        let url = URL(string: "https://api.datamuse.com/")!
        var req = URLRequest(url: url)
        parameters.forEach({ $0.modify(&req) })
        return req
    }
    
    private func makeRequest(_ path: String, with parameters: [AnyParameter]) -> URLRequest {
        makeRequest(with: [.init(path: path)] + parameters)
    }
    
    private func fetch<T: Decodable>(
        _ req: URLRequest,
        as type: T.Type = T.self,
    ) async throws -> T {
        let (data, response) = try await session.data(for: req)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(type, from: data)
    }
    
    private func fetch<T: Decodable>(
        _ path: String,
        with parameters: [AnyParameter],
        as type: T.Type = T.self,
    ) async throws -> T {
        try await fetch(makeRequest(path, with: parameters), as: type)
    }
}
