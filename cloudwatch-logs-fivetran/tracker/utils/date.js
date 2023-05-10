const previousDay = () => {
  const previousDay = new Date(now);
  return previousDay.setDate(now.getDate() - 1);
}

const endTime = () => {
  const day = previousDay()
  day.setHours(23);
  day.setMinutes(59);
  day.setSeconds(59);
  day.setMilliseconds(999);
  return day
}

const startTime = () => {
  const day = previousDay()
  day.setHours(0);
  day.setMinutes(0);
  day.setSeconds(0);
  day.setMilliseconds(0);
  return day
}

module.exports = {
  startTime,
  endTime
}
