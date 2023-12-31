//
//  GetData.swift
//  betterIC
//
//  Created by Claudio Rojas on 8/3/23.
//

import Foundation

struct Quarter: Decodable {
    let name: String
    let seq: Int
    let startDate: String
    let endDate: String
    let courses: [Course]
}

struct Course: Decodable, Identifiable {
    let id = UUID()
    let name: String
    let courseNumber: String
    let roomName: String
    let teacher: String
    let grades: Grades?
    let assignments: [Assignments]
    let attendance: Attendance
    let _id: Int
}

struct Grades: Decodable {
    let id = UUID()
    let score: String
    let percent: Float
    let totalPoints: Float
    let pointsEarned: Float
}

struct Attendance: Decodable {
    let absences: Int
    let tardies: Int
}

struct Assignments: Decodable {
    let id = UUID()
    let _id: Int
    let _idTerm: Int
    let termSeq: Int
    let category: String
    let weight: Float
    let name: String
    let assigned: String
    let due: String
    let gradedDate: String?
    let score: Float?
    let earnedPoints: Float?
    let totalPoints: Float
    let missing: Bool?
    let late: Bool?
}


//
//struct Placement: Decodable {
//    let periodName: String
//    let periodSeq: Int
//    let startTime: String
//    let endTime: String
//}


class GetData {
    private var root: [Quarter] = []
    private var inTerm: Int = 0
    
    func fetch (from urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let data = data { completion(.success(data))
                } else {
                    completion(.failure(NSError(domain: "Data not found", code: 0, userInfo: nil)))
                }
                
                
            }.resume()
        }

    }
    
    func processData (completion: @escaping ([Quarter]) -> Void) {
        fetch(from: "http://192.168.20.183:3000/api/courses") { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let decodedRoot = try decoder.decode([Quarter].self, from: data)
                    self.root = decodedRoot
                    print("root is empty: ", self.root.isEmpty)
                    print(self.root)
                    completion(self.root)
                } catch DecodingError.dataCorrupted(let context) {
                    print(context)
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch DecodingError.valueNotFound(let value, let context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("failed to retreive data")
                    completion([])
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func findQuarter() -> Int {
        if !self.root.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let currentDate = Date()

            if let quarter4StartDate = dateFormatter.date(from: self.root[3].startDate),
               let quarter4EndDate = dateFormatter.date(from: self.root[3].endDate),
               let quarter3StartDate = dateFormatter.date(from: self.root[2].startDate),
               let quarter3EndDate = dateFormatter.date(from: self.root[2].endDate),
               let quarter2StartDate = dateFormatter.date(from: self.root[1].startDate),
               let quarter2EndDate = dateFormatter.date(from: self.root[1].endDate),
               let quarter1StartDate = dateFormatter.date(from: self.root[0].startDate),
               let quarter1EndDate = dateFormatter.date(from: self.root[0].endDate) {
                
                if currentDate > quarter4StartDate && currentDate <= quarter4EndDate {
                    print("Student is in Quarter 4")
                    self.inTerm = 3
                } else if currentDate > quarter3StartDate && currentDate <= quarter3EndDate {
                    print("Student is in Quarter 3")
                    self.inTerm = 2
                } else if currentDate > quarter2StartDate && currentDate <= quarter2EndDate {
                    print("Student is in Quarter 2")
                    self.inTerm = 1
                } else if currentDate > quarter1StartDate && currentDate <= quarter1EndDate {
                    print("Student is in Quarter 1")
                    self.inTerm = 0
                } else {
                    self.inTerm = 0
                    print("Student is not in any quarter (has the school year started or ended?")
                }
            } else {
                print("Error parsing date strings")
            }
            return self.inTerm
        }
        return 0
    }
}
