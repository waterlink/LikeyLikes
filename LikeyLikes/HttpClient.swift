public protocol HttpClient {
    func get(url: String, handler: @escaping (String, Error?) -> Void)
}
