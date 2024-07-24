local AIO = AIO or require("AIO")

local ADDON_NAME = "AIOSlotMachine"
local PLAYER_EVENT_ON_COMMAND  = 42 -- (event, player, command, chatHandler) - player is nil if command used from console. Can return false

local SlotMachineHandlers = {}
AIO.AddHandlers("AIOSlotMachine", SlotMachineHandlers)
local SMHandlers = SlotMachineHandlers

SM.Wheels  = { -- Physical Wheels that are visible to the player
    [1] = { -- 1C 16, 2C 13, 3C 6, BG 1, XC 36
        "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C",
        "1C", "1C", "1C", "1C", "1C", "1C",
        "2C", "2C", "2C", "2C", "2C", "2C", "2C", "2C", "2C", "2C",
        "2C", "2C", "2C",
        "3C", "3C", "3C", "3C", "3C", "3C",
        "1BG",
    },
    [2] = { -- 1C 18, 2C 7, 3C 4, BG 1, XC 42
        "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C",
        "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C",
        "2C", "2C", "2C", "2C", "2C", "2C", "2C",
        "3C", "3C", "3C", "3C",
        "1BG", "1BG",
    },
    [3] = { -- 1C 20, 2C 4, 3C 3, BG 1, XC 44
        "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C",
        "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C",
        "2C", "2C", "2C", "2C",
        "3C", "3C", "3C",
        "1BG", "1BG",
    },
}

SM.VirtualWheels  = {
    [1] = { -- 1C 16, 2C 13, 3C 6, BG 1, XC 36
        "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C",
        "1C", "1C", "1C", "1C", "1C", "1C",
        "2C", "2C", "2C", "2C", "2C", "2C", "2C", "2C", "2C", "2C",
        "2C", "2C", "2C",
        "3C", "3C", "3C", "3C", "3C", "3C",
        "1BG",
        "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC",
        "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC",
        "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC",
    },
    [2] = { -- 1C 18, 2C 7, 3C 4, BG 1, XC 42
        "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C",
        "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C",
        "2C", "2C", "2C", "2C", "2C", "2C", "2C",
        "3C", "3C", "3C", "3C",
        "1BG",
        "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC",
        "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC",
        "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC",
        "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC",
        "XC", "XC",
    },
    [3] = { -- 1C 20, 2C 4, 3C 3, BG 1, XC 44
        "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C",
        "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C", "1C",
        "2C", "2C", "2C", "2C",
        "3C", "3C", "3C",
        "1BG",
        "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC",
        "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC",
        "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC",
        "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC", "XC",
        "XC", "XC", "XC", "XC",
    },
}

function SMHandlers.Print(player, ...)
    print(...)
end

local function OnCommand(event, player, command)
    if (command == "test") then
        AIO.Handle(player, ADDON_NAME, "ShowFrame")
        return false
    end
end

RegisterPlayerEvent(PLAYER_EVENT_ON_COMMAND, OnCommand)

