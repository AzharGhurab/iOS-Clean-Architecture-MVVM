import Foundation

struct MoviesRequestDTO: Encodable {
    let query: String
    let page: Int
}
struct MoviesListRequestDTO: Encodable {
    let page: Int
}
