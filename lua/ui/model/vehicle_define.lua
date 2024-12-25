local DEF = {}
DEF.VehicleType = {
  Mount = 1,
  Vehicle = 2,
  Platform = 3
}
DEF.PopType = {Property = 1, Skill = 2}
DEF.VehicleUseType = {
  land = 11,
  water = 12,
  landAndWater = 13
}
DEF.VehiclePeopleNum = {Single = 1, Multiple = 2}
DEF.ERideStage = {
  ERideNone = 0,
  ERideUp = 1,
  ERiding = 2,
  ERideDown = 3
}
return DEF
