local settings = {
    ["login_cameras"] = {
        enabled = true,
        config = {
            {
                start = {
                    position = Vector3(2003.5523681641, -1449.8708496094, 179.3498992919),
                    rotation = Vector3(0, 0, 70.91839599609)
                },
                finish = {
                    position = Vector3(1223.9947509766, -1863.9333496094, 157.92959594727),
                    rotation = Vector3(-10, 0, 340.86511230469)
                },
                easing = "Linear",
                time = 30 * 1000
            },
            {
                start = {
                    position = Vector3(-271.17001342773, 231.1381072998, 53.978298187256),
                    rotation = Vector3(351.9677734375, 0, 214.92309570313)
                },
                finish = {
                    position = Vector3(396.51119995117, -450.8623046875, 106.87419891357),
                    rotation = Vector3(347.03881835938, 0, 37.859130859375)
                },
                easing = "Linear",
                time = 30 * 1000
            },
            {
                start = {
                    position = Vector3(2021.6086425781, 1865.3211669922, 97.476699829102),
                    rotation = Vector3(348.50634765625, 0, 213.48217773438)
                },
                finish = {
                    position = Vector3(2480.784912109, 917.9423828125, 110.85289764404),
                    rotation = Vector3(348.88549804688, 0, 46.849670410156)
                },
                easing = "Linear",
                time = 30 * 1000
            }
        }
    }
}

function get(setting)
    return (settings[setting] and settings[setting].enabled) and settings[setting].config or false
end