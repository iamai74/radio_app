# Radio Browser API Usage

## Overview
This project uses the Radio Browser API to access community radio station data. The API is hosted at https://de2.api.radio-browser.info/

## API Endpoints

### General Information
- Base URL: https://de2.api.radio-browser.info/
- Server version: 0.7.43

### Data Endpoints

#### Countries
- Get list of countries: `GET /json/countries`
- Get countries with filter: `GET /json/countries/<filter>`

#### Languages
- Get list of languages: `GET /json/languages`
- Get languages with filter: `GET /json/languages/<filter>`

#### Tags
- Get list of tags: `GET /json/tags`
- Get tags with filter: `GET /json/tags/<filter>`

#### Radio Stations
- Search stations by name: `GET /json/stations/byname/{searchterm}`
- Search stations by country: `GET /json/stations/bycountry/{searchterm}`
- Get all stations: `GET /json/stations`

### Implementation Guidelines

1. All API requests should include a descriptive User-Agent header to help identify the application
2. Use appropriate HTTP methods (GET, POST)
3. Handle JSON responses for data parsing
4. Follow API request limits and avoid making excessive requests
5. Include error handling for network failures or API errors

### Swift Implementation Example

```swift
let url = URL(string: "https://de2.api.radio-browser.info/json/stations/byname/jazz")!
var request = URLRequest(url: url)
request.httpMethod = "GET"
request.setValue("RadioApp/1.0", forHTTPHeaderField: "User-Agent")

let task = URLSession.shared.dataTask(with: request) { data, response, error in
    // Handle response
    if let error = error {
        print("Error: \(error)")
        return
    }
    
    // Parse JSON response
    if let data = data {
        // Process the JSON data here
    }
}
task.resume()
```

### HTTP Headers
- Required: User-Agent header (e.g., "Cool Radio App/1.2")
- Optional: Accept header for format (application/json, application/xml)

### Response Formats
- JSON: Default format
- XML: `?format=xml`
- CSV: `?format=csv`

## API Usage Best Practices

1. Include descriptive User-Agent
2. Handle rate limiting
3. Cache responses when appropriate
4. Implement proper error handling
5. Consider using HTTPS connections only
6. Respect API request rates and avoid flooding