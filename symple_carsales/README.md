# Symple Car Sales - Car Buyer Script

A FiveM script for QBX framework that allows players to sell their vehicles to an NPC car buyer.

## Features

- **Map Blip**: Car buyer location is marked on the map
- **Proximity-Based NPC**: Ped only spawns when players are nearby (performance optimized)
- **Professional Appearance**: Suited businessman NPC for realistic experience
- **ox_target Integration**: Players can interact with the NPC using ox_target
- **Enhanced ox_lib Menus**: Rich, detailed menu system with metadata and confirmations
- **Database Integration**: Checks vehicle ownership and values from the database
- **Negotiation System**: Two offer options:
  - Quick Cash Deal: 50% of vehicle value (instant payment)
  - Bonus Package Deal: 40% of vehicle value + $1000 bonus

## Requirements

- QBX Core
- ox_lib
- ox_target
- oxmysql

## Installation

1. Ensure all dependencies are installed and running
2. Add `ensure symple_carsales` to your server.cfg
3. Restart your server

## Configuration

Edit `config/config.lua` to customize:

- **Car Buyer Location**: Change `carBuyer.coords` to move the NPC
- **NPC Model**: Change `carBuyer.model` to use a different ped (suited models available)
- **Proximity Settings**: Adjust spawn/despawn distances for performance
- **Blip Settings**: Customize the map blip appearance
- **Sale Percentages**: Adjust the offer percentages and bonus amount

## Usage

1. Players can find the car buyer via the blip on the map
2. Drive to the location in the vehicle you want to sell
3. Use ox_target to interact with the car buyer NPC
4. Choose from the negotiation options:
   - Accept 50% of vehicle value
   - Accept 40% of vehicle value + $1000 bonus
   - Decline the offer

## Database Requirements

The script requires:
- `player_vehicles` table with `citizenid` and `plate` columns
- `vehicles` table with `model` and `price` columns

## Notes

- Players must own the vehicle (checked via database)
- Players must be the driver of the vehicle
- Vehicle is automatically deleted after successful sale
- All transactions are logged to console