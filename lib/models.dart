class CityWeatherResponse {

  final WeatherInfo main;
  final List<WeatherDetailInfo> weather;
  final WeatherSysInfo sys;
  final WeatherWindInfo wind;
  final WeatherCoordInfo coord;

  const CityWeatherResponse({
    required this.main,
    required this.weather,
    required this.sys,
    required this.wind,
    required this.coord
  });

  factory CityWeatherResponse.fromJson(Map<String, dynamic> json) {
    final weatherData = json['weather'] as List<dynamic>?;
    final weather = weatherData != null
        ? weatherData.map((weatherDataItem) => WeatherDetailInfo.fromJson(weatherDataItem))
        .toList()
        : <WeatherDetailInfo>[];
    return CityWeatherResponse(
      main: WeatherInfo.fromJson(json['main'] as Map<String, dynamic>),
      weather: weather,
      sys: WeatherSysInfo.fromJson(json['sys'] as Map<String, dynamic>),
      wind: WeatherWindInfo.fromJson(json['wind'] as Map<String, dynamic>),
      coord: WeatherCoordInfo.fromJson(json['coord'] as Map<String, dynamic>)
    );
  }

}

class WeatherInfo {

  WeatherInfo({
    required this.temp,
    required this.humidity
  });

  final double temp;
  final int humidity;

  factory WeatherInfo.fromJson(Map<String, dynamic> data) {
    final temp = data['temp'] as double;
    final humidity = data['humidity'] as int;
    return WeatherInfo(
      temp: temp,
        humidity: humidity
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'humidity': humidity
    };
  }

}

class WeatherDetailInfo {

  WeatherDetailInfo({
    required this.main
  });

  final String main;

  factory WeatherDetailInfo.fromJson(Map<String, dynamic> data) {
    final main = data['main'] as String;
    return WeatherDetailInfo(main: main);
  }

  Map<String, dynamic> toJson() {
    return {
      'main': main
    };
  }

}

class WeatherSysInfo {

  WeatherSysInfo({
    required this.sunrise,
    required this.sunset
  });

  final int sunrise;
  final int sunset;

  factory WeatherSysInfo.fromJson(Map<String, dynamic> data) {
    final sunrise = data['sunrise'] as int;
    final sunset = data['sunset'] as int;
    return WeatherSysInfo(
      sunrise: sunrise,
      sunset: sunset
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sunrise': sunrise,
      'sunset': sunset
    };
  }

}

class WeatherWindInfo {

  WeatherWindInfo({
    required this.speed
  });

  final double speed;

  factory WeatherWindInfo.fromJson(Map<String, dynamic> data) {
    final speed = data['speed'] as double;
    return WeatherWindInfo(
      speed: speed
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speed': speed
    };
  }

}

class WeatherCoordInfo {

  WeatherCoordInfo({
    required this.lon,
    required this.lat
  });

  final double lon;
  final double lat;

  factory WeatherCoordInfo.fromJson(Map<String, dynamic> data) {
    final lon = data['lon'] as double;
    final lat = data['lat'] as double;
    return WeatherCoordInfo(
      lon: lon,
      lat: lat
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lon': lon,
      'lat': lat
    };
  }

}

class CityWeatherAQIResponse {

  final List<WeatherAQIWrapInfo> list;

  const CityWeatherAQIResponse({
    required this.list
  });

  factory CityWeatherAQIResponse.fromJson(Map<String, dynamic> json) {
    final listData = json['list'] as List<dynamic>?;
    final list = listData != null
      ? listData.map((listDataItem) => WeatherAQIWrapInfo.fromJson(listDataItem))
      .toList()
      : <WeatherAQIWrapInfo>[];
    return CityWeatherAQIResponse(
      list: list
    );
  }

}

class WeatherAQIWrapInfo {

  WeatherAQIWrapInfo({
    required this.main
  });

  final WeatherAQIInfo main;

  factory WeatherAQIWrapInfo.fromJson(Map<String, dynamic> data) {
    final main = data['main'] as WeatherAQIInfo;
    return WeatherAQIWrapInfo(main: main);
  }

  Map<String, dynamic> toJson() {
    return {
      'main': main
    };
  }

}

class WeatherAQIInfo {

  WeatherAQIInfo({
    required this.aqi
  });

  final int aqi;

  factory WeatherAQIInfo.fromJson(Map<String, dynamic> data) {
    final aqi = data['aqi'] as int;
    return WeatherAQIInfo(aqi: aqi);
  }

  Map<String, dynamic> toJson() {
    return {
      'aqi': aqi
    };
  }

}