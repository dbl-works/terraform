const previousHour = () => {
  const today = new Date()
  const hour = today.getHours()
  today.setHours(hour - 1)
  today.setMinutes(0)
  today.setSeconds(0)
  today.setMilliseconds(0)
  return today
}

const oneHourBefore = (date) => {
  const currentTime = date.getTime()
  return new Date(currentTime - 1 * 60 * 60 * 1000)
}

function startOfTheDay (date) {
  date.setUTCHours(0, 0, 0, 0)
  return date
}

function endOfTheDay (date) {
  date.setUTCHours(23, 59, 59, 999)
  return date
}

function previousDay (date) {
  date.setDate(date.getDate() - 1)
  return date
}

module.exports = {
  previousHour,
  oneHourBefore,
  startOfTheDay,
  endOfTheDay,
  previousDay
}
