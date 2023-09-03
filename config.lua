Config = {
	Debug = false, --change to true if you want to see debug messages in console
	UseCommand = true, --change to false if you don't want to use command
	shopName = "luxury", --change to your preferred vehicle shop name in your qb-core/shared/vehicles.lua
	targetResource = "ox", -- ox for ox_target, qb maybe soon.
	propModel = "v_serv_metro_advertstand1", --change to your preferred prop model
	targetLocs = {
		[1] = {
			targetId = "vehicle_catalogue", --UNIQUE
			point = vector3(-1258.94, -347.74, 36.86), --Vector3 coords
			UseLib = true, --Uses ox_lib context menu if true, else uses NUI
			pointHeading = 28.87, --Heading of Box Zone
			useProp = true, --Uses propModel if true
			distance = 3.0, --Distance to interact if using targetResource "dist" or target distance 
		},
		[2] = {
			targetId = "vehicle_catalogue2",
			point = vector3(-1262.67, -349.51, 36.81),
			UseLib = false,
			useProp = true,
			pointHeading = 28.87
		},
	},
}
