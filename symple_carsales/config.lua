-- ========================================
-- SYMPLE CAR SALES - CONFIGURATION
-- ========================================

return {
    -- Car Buyer NPC Configuration
    carBuyer = {
        coords = vec4(1224.8, 2727.66, 38.0, 178.65), -- Location of the car buyer NPC
        model = `s_m_m_fiboffice_02`, -- Well-dressed businessman in suit
        
        -- Alternative suited models you can use:
        -- `s_m_m_fiboffice_01` - FBI office worker in suit
        -- `s_m_m_ciasec_01` - CIA security in suit  
        -- `s_m_m_highsec_01` - High security in suit
        -- `s_m_y_dealer_01` - Car dealer (original)
        
        -- Proximity Settings (for performance optimization)
        spawnDistance = 50.0, -- Distance at which ped spawns
        deleteDistance = 75.0, -- Distance at which ped despawns
        
        -- Map Blip Settings
        blip = {
            sprite = 326, -- Car icon
            color = 2, -- Green
            scale = 0.8,
            name = "Car Buyer"
        }
    },
    
    -- Sale Offer Configuration
    saleOptions = {
        -- Base percentages (will be modified by various factors)
        option_a_base_percentage = 0.5, -- 50% base for Quick Cash Deal
        option_b_base_percentage = 0.4, -- 40% base for Bonus Package Deal
        option_b_bonus = 1000, -- Bonus amount added to option B
        
        -- Vehicle class multipliers (affects final percentage)
        classMultipliers = {
            [0] = 0.85,  -- Compacts (lower demand)
            [1] = 1.0,   -- Sedans (average)
            [2] = 1.1,   -- SUVs (higher demand)
            [3] = 1.05,  -- Coupes (slightly higher)
            [4] = 1.15,  -- Muscle (collectors like these)
            [5] = 1.2,   -- Sports Classics (high demand)
            [6] = 1.25,  -- Sports (very desirable)
            [7] = 1.3,   -- Super (premium vehicles)
            [8] = 0.9,   -- Motorcycles (niche market)
            [9] = 1.05,  -- Off-road (decent demand)
            [10] = 0.8,  -- Industrial (low demand)
            [11] = 0.85, -- Utility (low demand)
            [12] = 0.9,  -- Vans (limited market)
            [13] = 0.6,  -- Cycles (very low value)
            [14] = 1.0,  -- Boats (average)
            [15] = 1.4,  -- Helicopters (rare/expensive)
            [16] = 1.5,  -- Planes (very rare)
            [17] = 0.7,  -- Service (low demand)
            [18] = 0.75, -- Emergency (limited market)
            [19] = 1.2,  -- Military (collectors)
            [20] = 0.8,  -- Commercial (low demand)
            [21] = 0.5   -- Trains (almost no market)
        },
        
        -- Negotiation variance (random factor)
        variance_range = 0.05, -- ±5% random variation
        
        -- Vehicle condition impact
        condition_factor = true, -- Enable condition-based pricing
        max_condition_penalty = 0.3 -- Up to 30% reduction for damaged vehicles
    }
}