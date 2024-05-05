func pm2ToAqi(_ pm02: Float) -> Int {
  let breakpoints: [(cLow: Float, cHigh: Float, iLow: Int, iHigh: Int)] = [
    (0.0, 12.0, 0, 50),
    (12.1, 35.4, 51, 100),
    (35.5, 55.4, 101, 150),
    (55.5, 150.4, 151, 200),
    (150.5, 250.4, 201, 300),
    (250.5, 350.4, 301, 400),
    (350.5, 500.4, 401, 500),
  ]

  let pm25Rounded = Float(pm02 * 10).rounded() / 10  // Round to one decimal place if needed

  for breakpoint in breakpoints {
    if pm25Rounded >= breakpoint.cLow && pm25Rounded <= breakpoint.cHigh {
      let aqi =
        Float(breakpoint.iHigh - breakpoint.iLow) / (breakpoint.cHigh - breakpoint.cLow)
        * (pm25Rounded - breakpoint.cLow) + Float(breakpoint.iLow)
      return Int(aqi.rounded())
    }
  }

  // If PM2.5 is out of the highest range, return the maximum AQI value.
  return 500
}
