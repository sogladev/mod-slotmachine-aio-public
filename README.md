# Module Slot Machine Public

This is a module compatible for [AzerothCore](http://www.azerothcore.org), [ElunaTrinityWotlk](https://github.com/ElunaLuaEngine/ElunaTrinityWotlk) that implements a 3x3 slot machine with ElunaLUA and AIO

Eluna AIO module for AzerothCore

## Features
* based on real classic 3x3 slot machine
* database persistence, no bets are lost
* configurable skins
* sound effects
* emotes
* easily configurable to use gold or item as currency
* payout to character unless gold cap / bags full then through ingame mail
* announce wins locally or server-wide with configurable conditions
* configuration to change announcement, messages, mail, database
* sim included to adjust payout table, hit frequency and return value
* adaptable to change payout handling e.g. custom items on mini-jackpot or jackpot

ui: ![slots_ui_wide](https://github.com/user-attachments/assets/25ba63d2-3dfe-4425-be5c-beb23438ce88)


in action short: 

https://github.com/user-attachments/assets/5e1601d0-2f1d-412f-9f82-2a8bd33a0e9c


in action 4min video:
- bid with gold: spins, effects, ui options, sound effects, skins, payouts, etc.
- bid with emblems: example eof
- custom jackpot: timer mount on jackpot
  
https://www.youtube.com/watch?v=axqYfxsfyqg

## Customization
SM.Config
SM.Currency: change icons, bets, etc
modify database to use

any custom handling for items can be done in the Payout method on server-side

Virtual Reels and CalculatePayout decide odds, use provided notebook to modify the payouttable or modify virtual reels

0.957 RTP with 0.281 hit frequency. These values will be exactly calculated on startup, can be disabled in SM.Config
```
AIOSlotMachine:SimInfo return: 0.956988 hits: 0.281041
```

## How to play:
`.slots` to open the window
any misses payout will be added next play or manually in case of a server crash by `.slotspayout` to receive any payouts without playing again

See menu for winning combinations and pay value

## Database
Requires a table `slot_machine`. This table will be auto generated on launch.

## Requirements

https://github.com/Rochet2/AIO/tree/master

## Sources

## How to create your own module

1. Use the script `create_module.sh` located in [`modules/`](https://github.com/azerothcore/azerothcore-wotlk/tree/master/modules) to start quickly with all the files you need and your git repo configured correctly (heavily recommended).
1. You can then use these scripts to start your project: https://github.com/azerothcore/azerothcore-boilerplates
1. Do not hesitate to compare with some of our newer/bigger/famous modules.
1. Edit the `README.md` and other files (`include.sh` etc...) to fit your module. Note: the README is automatically created from `README_example.md` when you use the script `create_module.sh`.
1. Publish your module to our [catalogue](https://github.com/azerothcore/modules-catalogue).
