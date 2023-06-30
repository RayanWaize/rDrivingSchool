Config = {
    newESX = false, -- Est que vous utilisez la nouvelle declaration ESX ?
    menuPermisInfo = { -- Les points des Gestions des permis (Vous pouvez choisir la pos et la job)
        {jobName = 'police', posMenu = vector3(443.53, -975.0, 30.69)},
    },
    permisdecision = false, -- true pour regrouper les 3 permis (voiture, moto, camion) en 1 /////// false pour avoir 3 permis différent (voiture, moto, camion)
    cmdplayer = "permis", -- Commande pour ouvrir menu pour savoir Combien de points vous avez.
    modDev = false, -- Activer ou desactiver le mode dev pour test les Attribution des permis.
    allPos = {
        posCoffre = vector3(231.99, 376.73, 106.11),
        posGarage = vector3(237.14, 380.11, 106.26),
        posGarageSpawn = vector4(240.47, 383.3, 106.04, 75.568),
        posMenuBoss = vector3(227.22, 378.54, 106.11),
    },
    garageCar = {
        {label = "Voiture", model = "rhapsody"},
        {label = "Moto", model = "bati"},
        {label = "Camion", model = "mule"},
    }
}