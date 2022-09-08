const previousHour = () => {
  const today = new Date()
  const lastHour = today.getHours() - 1
  today.setUTCHours(lastHour, 0, 0, 0)
  return today
}

const oneHourBefore = (time) => {
  const currentTime = time.getTime()
  return new Date(currentTime - 1 * 60 * 60 * 1000)
}

function startOfTheDay (time) {
  time.setUTCHours(0, 0, 0, 0)
  return time
}

function endOfTheDay (time) {
  time.setUTCHours(23, 59, 59, 999)
  return time
}

function previousDay (time) {
  time.setDate(time.getDate() - 1)
  return time
}

module.exports = {
  previousHour,
  oneHourBefore,
  startOfTheDay,
  endOfTheDay,
  previousDay
}
