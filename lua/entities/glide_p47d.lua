-- Example car class
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_plane"
ENT.PrintName = "P-47D"
ENT.Author = ".kkrill"

ENT.GlideCategory = "ClassicPlanes"
ENT.ChassisModel = "models/p-47 (fly).mdl"
ENT.MaxChassisHealth = 800

DEFINE_BASECLASS( "base_glide_plane" )

function ENT:SetupDataTables()
    BaseClass.SetupDataTables( self )

    self:NetworkVar( "Bool", "FiringGun" )
    self:NetworkVar( "Float", "LandingGearExtend" )
end

if CLIENT then
    ENT.CameraOffset = Vector( -500, 0, 150 )
    ENT.CameraCenterOffset = Vector( 0, 0, 80 )

    ENT.StartSoundPath = "lfs/cessna/start.mp3"
    ENT.DistantSoundPath = "LFS_SPITFIRE_DIST"

    ENT.EngineSoundPath = "LFS_CESSNA_RPM4"
    ENT.EngineSoundLevel = 90
    ENT.EngineSoundVolume = 0.6
    ENT.EngineSoundMinPitch = 80
    ENT.EngineSoundMaxPitch = 120

    ENT.WeaponInfo = {
        { name = "#glide.weapons.mgs", icon = "glide/icons/bullets.png" },
        { name = "#glide.weapons.missiles", icon = "glide/icons/rocket.png" },
    }

    ENT.CrosshairInfo = {
        { iconType = "dot", traceOrigin = Vector( 141.83, 0, 68.4 ) },
        { iconType = "square", traceOrigin = Vector( 94, 0, 57.5 ) },
    }

    ENT.ExhaustPositions = {

    }

    ENT.StrobeLights = {

    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 164.8, 0, 112 ), angle = Angle( 90, 0, 50 ), scale = 0.5 },
    }

    function ENT:OnActivateMisc()
        BaseClass.OnActivateMisc( self )

        self.rotorBone = self:LookupBone( "Propeller" )
        self.rotorAngle = Angle()
        self.rotorIsSpinningFast = false
        self.rudderBone = self:LookupBone( "Ruder" )
        self.elevatorBone = self:LookupBone( "Elevator" )
        self.aileronRBone = self:LookupBone( "Right Aerlion" )
        self.aileronLBone = self:LookupBone( "Left Aerlion" )
    end

    local ang = Angle()

    function ENT:OnUpdateAnimations()
        if not self.rudderBone then return end

        local isSpinningFast =  self:GetPower() > 0.65

        if self.isSpinningFast != isSpinningFast then
            self.isSpinningFast = isSpinningFast
            self:SetBodygroup( 12, isSpinningFast and 0 or 1 )
        end

        local dt = FrameTime()
        self.rotorAngle.p = ( self.rotorAngle.p + 5000 * self:GetPower() * dt ) % 360

        self:ManipulateBoneAngles( self.rotorBone, self.rotorAngle )

        ang[1] = 0
        ang[2] = 0
        ang[3] = self:GetElevator() * -25

        self:ManipulateBoneAngles( self.elevatorBone, ang )

        ang[1] = self:GetRudder() * 15
        ang[3] = 0
        ang[2] = 0

        self:ManipulateBoneAngles( self.rudderBone, ang )

        local aileron = self:GetAileron()

        ang[2] = 0
        ang[1] = aileron * -25
        ang[3] = 0

        self:ManipulateBoneAngles( self.aileronRBone, ang )

        ang[2] = 0
        ang[1] = aileron * -25
        ang[3] = 0

        self:ManipulateBoneAngles( self.aileronLBone, ang )

        self:AnimateLandingGear()
    end

    -- NOTE: i have no idea if the name LandingGearAngle is accurate here, but if you have any other suggestions about
    -- what SMRG and SMLG could mean, i would love to hear them
    ENT.LandingGearAngle = 0
    function ENT:AnimateLandingGear()
        self.LandingGearAngle = self.LandingGearAngle + ( ( 1 - self:GetLandingGearExtend() ) - self.LandingGearAngle ) * FrameTime() * 8

        local landingGearAngle = self.LandingGearAngle

        local gExp = landingGearAngle ^ 15 -- ????????

        ang[1] = -30 + 30 * landingGearAngle
        ang[2] = 0
        ang[3] = 0

        self:ManipulateBoneAngles( 13, ang )

        ang[1] = 30 - 30 * landingGearAngle
        ang[2] = 0
        ang[3] = 0

        self:ManipulateBoneAngles( 14, ang )

        ang[1] = 3.5 * landingGearAngle
        ang[2] = 88 * landingGearAngle
        ang[3] = 24.5 * landingGearAngle

        self:ManipulateBoneAngles( 42, ang )

        ang[1] = 0
        ang[2] = -90 * gExp
        ang[3] = 2.8 * gExp

        self:ManipulateBoneAngles( 45, ang )

        ang[1] = -3.5 * landingGearAngle
        ang[2] = -88 * landingGearAngle
        ang[3] = 24.5 * landingGearAngle

        self:ManipulateBoneAngles( 43, ang )

        ang[1] = 0
        ang[2] = 90 * gExp
        ang[3] = 2.8 * gExp

        self:ManipulateBoneAngles( 44, ang )

        ang[1] = -5.5 * gExp
        ang[2] = 90 * gExp
        ang[3] = -16 * gExp

        self:ManipulateBoneAngles( 47, ang )

        ang[1] = 5 * gExp
        ang[2] = -90 * gExp
        ang[3] = -16 * gExp

        self:ManipulateBoneAngles( 48, ang )

        ang[1] = 0
        ang[2] = 0
        ang[3] = 160 * landingGearAngle

        self:ManipulateBoneAngles( 46, ang )
    end

    function ENT:OnUpdateSounds()
        BaseClass.OnUpdateSounds( self )

        local sounds = self.sounds

        if self:GetFiringGun() then
            if not sounds.gunFire then
                local gunFire = self:CreateLoopingSound( "gunFire", "SPITFIRE_FIRE_LOOP", 95, self )
                gunFire:PlayEx( 1.0, 100 )
            end

        elseif sounds.gunFire then
            sounds.gunFire:Stop()
            sounds.gunFire = nil

            self:EmitSound( "SPITFIRE_FIRE_LASTSHOT" )
        end
    end
end

if SERVER then
    ENT.ChassisMass = 1400
    ENT.SpawnPositionOffset = Vector( 0, 0, 40 )

    ENT.ExplosionGibs = {
        "models/p-47 (fly).mdl"
    }

    ENT.PropModel = ""
    ENT.PropFastModel = ""

    ENT.HasLandingGear = true

    -- Plane drag & force constants
    ENT.PlaneParams = {
        -- These drag forces only apply
        -- when flying at max. liftSpeed.
        liftAngularDrag = Vector( -5, -10, -3 ), -- (Roll, pitch, yaw)
        liftForwardDrag = 0.1,
        liftSideDrag = 3,

        liftFactor = 0.15,       -- How much of the up velocity to negate
        maxSpeed = 2350,        -- Speed limit
        liftSpeed = 1600,       -- Speed required to float
        controlSpeed = 1200,    -- Speed required to have complete control of the plane

        engineForce = 200,
        alignForce = 300,

        pitchForce = 1000,
        yawForce = 500,
        rollForce = 1200
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 40, 0, 85.8 ), Angle( 0, -90, 0 ), Vector( -53.3, 117.8, 23.3 ), true )

        self.wheelParams.suspensionLength = 38
        self.wheelParams.springStrength = 1500
        self.wheelParams.springDamper = 6000
        self.wheelParams.brakePower = 2000
        self.wheelParams.sideTractionMultiplier = 250

        -- Front left
        self:CreateWheel( Vector( 115.22, 104.53, 44 ), {
            radius = 18
        } )

        -- Front right
        self:CreateWheel( Vector( 115.22, -104.53, 44 ), {
            radius = 18
        } )

        -- Rear
        self:CreateWheel( Vector( -161.67, 0, 95 ), {
            radius = 8,
            steerMultiplier = -1
        } )

        self:SetBodygroup( 12, 1 )
        self:SetBodygroup( 15, 1 )

        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end

        -- default inertia fucks shit up. seems to be a common theme with these models
        self:GetPhysicsObject():SetInertia( Vector( 2800, 2800, 2800 ) )
    end

    function ENT:GetSpawnColor()
        return Color( 255, 255, 255 )
    end

    ENT.WeaponSlots = {
        { maxAmmo = 0, fireRate = 0.03, replenishDelay = 0, ammoType = "explosive_cannon" },
        { maxAmmo = 10, fireRate = 0.1, replenishDelay = 6, ammoType = "missile" },
    }

    ENT.GunNum = 1

    local firingOffsets = {
        Vector( 141.83, -121.84, 68.4 ),
        Vector( 141.83, 121.84, 68.4 ),
        Vector( 136.44, -128.69, 68.49 ),
        Vector( 136.44, 128.69, 68.49 ),
        Vector( 129.23, -135.24, 68.31 ),
        Vector( 129.23, 135.24, 68.31 ),
        Vector( 122.84, -142.46, 68.32 ),
        Vector( 122.84, 142.46, 68.32 )
    }

    ENT.MissileNum = 1

    local missileOffsets = {
        Vector( 92.16, -194.69, 62.98 ),
        Vector( 92.16, 194.69, 62.98 ),
        Vector( 92.63, -178.76, 61.32 ),
        Vector( 92.63, 178.76, 61.32 ),
        Vector( 93.54, -163.72, 59.4 ),
        Vector( 93.54, 163.72, 59.4 ),
        Vector( 93.96, -132.84, 55.58),
        Vector( 93.96, 132.84, 55.58 ),
        Vector( 94, -118.52, 53.9 ),
        Vector( 94, 118.52, 53.9 )
    }

    function ENT:OnWeaponFire( weapon )
        local attacker = self:GetSeatDriver( 1 )

        if weapon.ammoType == "explosive_cannon" then
            self:SetFiringGun( true )

            self:FireBullet( {
                pos = self:LocalToWorld( firingOffsets[ self.GunNum ] ),
                ang = self:LocalToWorldAngles( Angle( 0, firingOffsets[ self.GunNum ].y > 0 and -2 or 2, 0 ) ),
                attacker = attacker,
                spread = 0.018,
                damage = 32,
            } )

            self.GunNum = self.GunNum % 8 + 1
        else
            local pos = self:LocalToWorld( missileOffsets[ self.MissileNum ] )
            self:FireMissile( pos, self:GetAngles(), attacker )
            self.MissileNum = self.MissileNum % 10 + 1
        end
    end

    function ENT:OnWeaponStop()
        self:SetFiringGun( false )
    end

    function ENT:LandingGearThink( ... )
        BaseClass.LandingGearThink( self, ... )

        -- holy SHIT i was convinced this would be very messy
        self:SetLandingGearExtend( self.landingGearExtend )
    end
end