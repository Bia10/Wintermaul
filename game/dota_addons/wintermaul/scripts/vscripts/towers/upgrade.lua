-- called when a sell_tower_x ability is cast
require('libraries/buildinghelper')
function UpgradeTower(keys)
    print('is thing on')
    local building = keys.caster
    local newBuildingName = keys.new_tower_name
    if building:GetHealth() == building:GetMaxHealth() then -- only allow selling if the building is fully built
        BuildingHelper:UpgradeBuilding(building, newBuildingName)
    end
end