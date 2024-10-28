local forcedWeapons = {
    "weapon_pistol", "weapon_pistol_mk2", "weapon_combatpistol", 
    "weapon_ceramicpistol", "weapon_minismg", "weapon_microsmg", 
    "weapon_sawnoffshotgun", "weapon_assaultrifle", 
    "weapon_assaultrifle_mk2", "weapon_compactrifle"
}

local recoilSettings = {
    ["weapon_pistol"] = { recoil = 0.5, screenShake = 0.1 },
    ["weapon_pistol_mk2"] = { recoil = 0.6, screenShake = 0.15 },
    ["weapon_combatpistol"] = { recoil = 0.55, screenShake = 0.12 },
    ["weapon_ceramicpistol"] = { recoil = 0.45, screenShake = 0.08 },
    ["weapon_minismg"] = { recoil = 0.7, screenShake = 0.2 },
    ["weapon_microsmg"] = { recoil = 0.75, screenShake = 0.25 },
    ["weapon_sawnoffshotgun"] = { recoil = 1.0, screenShake = 0.5 },
    ["weapon_assaultrifle"] = { recoil = 0.9, screenShake = 0.4 },
    ["weapon_assaultrifle_mk2"] = { recoil = 1.1, screenShake = 0.35 },
    ["weapon_compactrifle"] = { recoil = 0.85, screenShake = 0.28 }
}

local headshotDeath = true -- Set to true for instant death on headshot

-- Function to disable gun melee/slaying
local function DisableWeaponMelee()
    local ped = PlayerPedId()
    if IsPedArmed(ped, 6) then -- Check if the player is using a firearm
        DisableControlAction(0, 140, true) -- Disable melee attack (R)
        DisableControlAction(0, 141, true) -- Disable melee light attack
        DisableControlAction(0, 142, true) -- Disable melee heavy attack
    end
end

-- Function to check if the weapon has a grip
local function HasWeaponGrip(weapon)
    local gripHash = GetHashKey("COMPONENT_AT_AR_AFGRIP") -- Standard grip component
    return HasPedGotWeaponComponent(PlayerPedId(), weapon, gripHash)
end

-- Function to apply custom recoil and screen shake
local function ApplyWeaponRecoilAndShake()
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)

    if recoilSettings[weapon] then
        local recoil = recoilSettings[weapon].recoil
        local shake = recoilSettings[weapon].screenShake

        -- If the weapon has a grip, reduce the shake
        if HasWeaponGrip(weapon) then
            shake = shake * 0.5 -- Reduce screen shake by 50%
        end

        -- Apply screen shake
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', shake)

        -- Apply recoil force
        local pitch = GetGameplayCamRelativePitch()
        SetGameplayCamRelativePitch(pitch + recoil, 1.0)
    end
end

-- Function to check for headshots and apply instant death
local function CheckHeadshotDeath()
    if headshotDeath then
        local ped = PlayerPedId()
        local weapon = GetSelectedPedWeapon(ped)

        if HasEntityBeenDamagedByWeapon(ped, weapon, 0) then
            local hitBone, bone = GetPedLastDamageBone(ped)
            if bone == 31086 then -- Head bone
                SetEntityHealth(ped, 0) -- Instant death
            end
        end
    end
end

-- Function to handle first-person aiming
local function ForceFirstPersonAim()
    local ped = PlayerPedId()
    local currentWeapon = GetSelectedPedWeapon(ped)

    if IsPlayerFreeAiming(PlayerId()) then
        HideHudComponentThisFrame(14) -- Hide reticle

        -- Check if the current weapon is in the forced weapons list
        for _, weapon in ipairs(forcedWeapons) do
            if GetHashKey(weapon) == currentWeapon then
                -- Force first-person view when aiming
                SetFollowPedCamViewMode(4)
                return
            end
        end
    else
        SetFollowPedCamViewMode(1) -- Default third-person view
    end
end

-- Main loop to handle events
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        DisableWeaponMelee()
        ForceFirstPersonAim()
        ApplyWeaponRecoilAndShake()
        CheckHeadshotDeath()
    end
end)

-- Helper function to check if a value exists in a table
function table.contains(table, element)
    for _, value in ipairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
