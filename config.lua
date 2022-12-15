Config = Config or {}
Config.Gainii = {}

-- start plant settings
Config.GrowthTimer = 600 --  1000 = 1 minut
Config.StartingThirst = math.random(70.0,100.0) -- starting plan thirst percentage
Config.StartingHunger = math.random(70.0,100.0) -- starting plan hunger percentage
Config.HungerIncrease = 30.0 -- amount increased when watered
Config.ThirstIncrease = 30.0 -- amount increased when fertilizer is used
Config.Degrade = {min = 1, max = 5}
Config.QualityDegrade = {min = 2, max = 12}
Config.GrowthIncrease = {min = 10, max = 20}
Config.MaxGainiCount = 2 -- maximum plants play can have at any one time
Config.DrugEffect = false -- true/false if you want to have drug effect occur
Config.DrugEffectTime = 300000 -- drug effect time in milliseconds
Config.YieldRewards = {
    {type = "oua",          rewardMin = 1, rewardMax = 2, item = 'oua',        labelos = 'Oua'},
    {type = "pene",         rewardMin = 5, rewardMax = 6, item = 'pene',       labelos = 'Pene'},

}
-- end plant settings
