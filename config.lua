Config = {
	Debug = true, --change to true if you want to see debug messages in console
    useCommand = true, --change to false if you don't want to use command
	shopName = "luxury", --change to your preferred vehicle shop name in your qb-core/shared/vehicles.lua
	targetResource = "ox", -- ox for ox_target, qb maybe soon. 
	propModel = "v_serv_metro_advertstand1", --change to your preferred prop model
	targetLocs = {
		[1] = {
			targetId = "vehicle_catalogue", --UNIQUE
			point = vector3(-1257.96, -347.17, 36.88), --Vector3 coords
			useLib = true, --Uses ox_lib context menu if true, else uses NUI
			pointHeading = 28.87,
			minZ = 26,
			maxZ = 30,
			useProp = true, --Uses propModel if true
		},
		[2] = {
			targetId = "vehicle_catalogue2",
			point = vector3(-1262.74, -349.42, 36.81),
			useLib = false,
			pointHeading = 23.37,
			minZ = 26,
			maxZ = 30,
			useProp = false,
		},
	},
}
