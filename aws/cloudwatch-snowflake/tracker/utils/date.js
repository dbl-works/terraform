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

module.exports = {
  previousHour,
  oneHourBefore
}
