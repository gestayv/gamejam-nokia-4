-- Pet class, contains pet info and its cute stuffs
Pet = Class{}

-- Pet stats constants
MAX_ENERGY = 100
MIN_ENERGY = 0

-- Pet buff constants
FIRERATE_RATE = 0.1
DAMAGE_RATE = 1
NULLIF_RATE = 0.5
DMGRED_RATE = 5
HEALING_RATE = 10
HEALTH_RATE = 10

-- Pet time constants
ENERGY_TICK = 5


function Pet:init()
    -- Pet stats
    self.energy = 50
    self.saturation = ''

    -- Damage buffs
    self.fireRateStack = 0
    self.damageStack = 0

    -- Defense buffs
    self.nullificationStack = 0
    self.damageReductionStack = 0

    -- Health buffs
    self.healingStack = 0
    self.healthStack = 0

    -- Time variables
    self.dtTime = 0

end

function Pet:update(dt)
    self:reduceEnergy(dt)
end

function Pet:feed(food)
    local addedEnergy = 20
    if food == 'fireRate' then
        self.fireRateStack = self.fireRateStack + 1
        if food == self.saturation then
            addedEnergy = 5
        end
        self.saturation = 'fireRate'
    elseif food == 'damage' then
        self.damageStack = self.damageStack + 1
        if food == self.saturation then
            addedEnergy = 5
        end
        self.saturation = 'damage'
    elseif food == 'nullification' then
        self.nullificationStack = self.nullificationStack + 1
        if food == self.saturation then
            addedEnergy = 5
        end
        self.saturation = 'nullification'
    elseif food == 'damageReduction' then
        self.damageReductionStack = self.damageReductionStack + 1
        if food == self.saturation then
            addedEnergy = 5
        end
        self.saturation = 'damageReduction'
    elseif food == 'healing' then
        self.healingStack = self.healingStack + 1
        if food == self.saturation then
            addedEnergy = 5
        end
        self.saturation = 'healing'
    elseif food == 'health' then
        self.healthStack = self.healthStack + 1
        if food == self.saturation then
            addedEnergy = 5
        end
        self.saturation = 'health'
    else 
        return false
    end

    self:increaseEnergy(addedEnergy)

    return true
end

function Pet:reduceEnergy(dt)
    self.dtTime = self.dtTime + dt
    if self.dtTime >= ENERGY_TICK then
        self.dtTime = self.dtTime - ENERGY_TICK
        if self.energy > 0 then
            self.energy = self.energy - 1
        end
    end
end

function Pet:increaseEnergy(q)
    if self.energy + q > 100 then
        self.energy = 100
    else
        self.energy = self.energy + q
    end
end

function Pet:getBuff(type)
    if type == 'fireRate' then
        return self.fireRateStack * FIRERATE_RATE
    elseif type == 'damage' then
        return self.damageStack * DAMAGE_RATE
    elseif type == 'nullification' then
        return self.nullificationStack * NULLIF_RATE
    elseif type == 'damageReduction' then
        return self.damageReductionStack * DMGRED_RATE
    elseif type == 'healing' then
        return self.healingStack * HEALING_RATE
    elseif type == 'health' then
        return self.healthStack * HEALTH_RATE
    else 
        return 666
    end
end