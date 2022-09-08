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

module.exports = {
  previousHour,
  oneHourBefore
}
