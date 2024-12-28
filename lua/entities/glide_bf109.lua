-- Example car class
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_plane"
ENT.PrintName = "BF 109"
ENT.Author = ".kkrill"

ENT.GlideCategory = "ClassicPlanes"
ENT.ChassisModel = "models/blu/bf109.mdl"
ENT.MaxChassisHealth = 800

DEFINE_BASECLASS( "base_glide_plane" )

function ENT:SetupDataTables()
    BaseClass.SetupDataTables( self )

    self:NetworkVar( "Int", "FiringGun" )
    -- self:NetworkVar( "Bool", "FiringGun2" ) -- lazy
    self:NetworkVar( "Float", "LandingGearExtend" )
end

if CLIENT then
    ENT.CameraOffset = Vector( -500, 0, 150 )
    ENT.CameraCenterOffset = Vector( 0, 0, 80 )

    ENT.StartSoundPath = "lfs/bf109/start.mp3"
    ENT.DistantSoundPath = "LFS_BF109_DIST"

    ENT.EngineSoundPath = "LFS_BF109_RPM4"
    ENT.EngineSoundLevel = 90
    ENT.EngineSoundVolume = 0.6
    ENT.EngineSoundMinPitch = 80
    ENT.EngineSoundMaxPitch = 120

    ENT.WeaponInfo = {
        { name = "Primary Cannon", icon = "glide/icons/bullets.png" },
        { name = "Secondary Cannon", icon = "glide/icons/bullets.png" },
    }

    ENT.CrosshairInfo = {
        { iconType = "dot", traceOrigin = Vector( 109.29, 0, 92.85 ) },
        { iconType = "dot", traceOrigin = Vector( 93.58, 0, 63.63 ) },
    }

    ENT.ExhaustPositions = {
        Vector( 129.28, 17.85, 68.91 ),
        Vector( 122.79, 17.88, 69.14 ),
        Vector( 114.7, 18.9, 69.11 ),
        Vector( 107.43, 19.74, 68.82 ),
        Vector( 99.56, 20.28, 69.05 ),
        Vector( 91.97, 20.31, 68.9 ),
    }

    ENT.StrobeLights = {

    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 128, 0, 96 ), angle = Angle( 90, 0, 50 ), scale = 0.5 },
    }

    function ENT:OnActivateMisc()
        BaseClass.OnActivateMisc( self )

        self.rotorBone = self:LookupBone( "propeller" )
        self.rotorAngle = Angle()
        self.rotorIsSpinningFast = false
        self.rudderBone = self:LookupBone( "Rudder" )
        self.elevatorBone = self:LookupBone( "Elevator" )
        self.aileronRBone = self:LookupBone( "Left aileron" )
        self.aileronLBone = self:LookupBone( "Right aileron" )
    end

    local ang = Angle()

    function ENT:OnUpdateAnimations()
        if not self.rudderBone then return end

        local isSpinningFast =  self:GetPower() > 0.65

        if self.isSpinningFast != isSpinningFast then
            self.isSpinningFast = isSpinningFast
            self:SetBodygroup( 14, isSpinningFast and 0 or 1 )
        end

        local dt = FrameTime()
        self.rotorAngle.p = ( self.rotorAngle.p + 5000 * self:GetPower() * dt ) % 360

        self:ManipulateBoneAngles( self.rotorBone, self.rotorAngle )

        ang[1] = 0
        ang[2] = 0
        ang[3] = self:GetElevator() * -25

        self:ManipulateBoneAngles( self.elevatorBone, ang )

        ang[1] = self:GetRudder() * -20
        ang[2] = 0
        ang[3] = 0

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
        self.LandingGearAngle = self.LandingGearAngle + ( 80 * self:GetLandingGearExtend() - self.LandingGearAngle ) * FrameTime() * 8

        local landingGearAngle = self.LandingGearAngle

        ang[1] = landingGearAngle
        ang[2] = 0
        ang[3] = 0

        self:ManipulateBoneAngles( 8, ang )

        ang[1] = -landingGearAngle
        ang[2] = 0
        ang[3] = 0

        self:ManipulateBoneAngles( 9, ang )

        ang[1] = -landingGearAngle / 2
        ang[2] = 0
        ang[3] = 0

        self:ManipulateBoneAngles( 3, ang )

        ang[1] = landingGearAngle / 2
        ang[2] = 0
        ang[3] = 0

        self:ManipulateBoneAngles( 4, ang )
    end

    function ENT:OnUpdateSounds()
        BaseClass.OnUpdateSounds( self )

        local sounds = self.sounds

        if self:GetFiringGun() == 1 then
            if not sounds.gunFire then
                local gunFire = self:CreateLoopingSound( "gunFire", "BF109_FIRE_LOOP", 95, self )
                gunFire:PlayEx( 1.0, 100 )
            end
        elseif sounds.gunFire then
            sounds.gunFire:Stop()
            sounds.gunFire = nil

            self:EmitSound( "BF109_FIRE_LASTSHOT" )
        end


        if self:GetFiringGun() == 2 then
            if not sounds.gunFire2 then
                local gunFire2 = self:CreateLoopingSound( "gunFire2", "BF109_FIRE2_LOOP", 95, self )
                gunFire2:PlayEx( 1.0, 100 )
            end
        elseif sounds.gunFire2 then
            sounds.gunFire2:Stop()
            sounds.gunFire2 = nil

            self:EmitSound( "BF109_FIRE2_LASTSHOT" )
        end
    end
end

if SERVER then
    ENT.ChassisMass = 1200
    ENT.SpawnPositionOffset = Vector( 0, 0, 40 )

    ENT.ExplosionGibs = {
        "models/blu/bf109.mdl"
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
        self:CreateSeat( Vector( 26, 0, 63 ), Angle( 0, -90, 0 ),  Vector( -54.4, 68.3, 37.8 ) , true )

        self.wheelParams.suspensionLength = 38
        self.wheelParams.springStrength = 1500
        self.wheelParams.springDamper = 6000
        self.wheelParams.brakePower = 2000
        self.wheelParams.sideTractionMultiplier = 250

        -- Front left
        self:CreateWheel( Vector( 78.12, 55, 50 ), {
            radius = 13
        } )

        -- Front right
        self:CreateWheel( Vector( 78.12, -55, 50 ), {
            radius = 13
        } )

        -- Rear
        self:CreateWheel( Vector( -146.61, 0, 112 ), {
            radius = 13,
            steerMultiplier = -1
        } )

        self:SetBodygroup( 13, 1 )
        self:SetBodygroup( 14, 1 )

        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end

        -- AAAAAAAAAAAAAAAAAAAAA
        local phys = self:GetPhysicsObject()
        phys:SetInertia( phys:GetInertia() * 0.25 )
        phys:SetDamping( 0, 0 )
    end

    function ENT:GetSpawnColor()
        return Color( 255, 255, 255 )
    end

    ENT.WeaponSlots = {
        { maxAmmo = 0, fireRate = 0.03, replenishDelay = 0, ammoType = "gun1" },
        { maxAmmo = 0, fireRate = 0.15, replenishDelay = 0, ammoType = "gun2" },
    }

    ENT.Mirror = 1

    function ENT:OnWeaponFire( weapon )
        local attacker = self:GetSeatDriver( 1 )

        if weapon.ammoType == "gun1" then
            self:SetFiringGun( 1 )

            self:FireBullet( {
                pos = self:LocalToWorld( Vector( 109.29, 7.13 * self.Mirror, 92.85 ) ),
                ang = self:GetAngles(),
                attacker = attacker,
                spread = 0.015,
                damage = 10,
            } )

            self.Mirror = -self.Mirror
        else
            self:SetFiringGun( 2 )

            self:FireBullet( {
                pos = self:LocalToWorld( Vector( 93.58, 85.93 * self.Mirror, 63.63 ) ),
                ang = self:LocalToWorldAngles( Angle( 0,-0.5 * self.Mirror, 0 ) ),
                attacker = attacker,
                spread = 0.015,
                damage = 125,
            } )

            self.Mirror = -self.Mirror
        end
    end

    function ENT:OnWeaponStop()
        self:SetFiringGun( 0 )
    end

    function ENT:LandingGearThink( ... )
        BaseClass.LandingGearThink( self, ... )

        -- holy SHIT i was convinced this would be very messy
        self:SetLandingGearExtend( self.landingGearExtend )
    end
end

sound.Add( {
    name = "BF109_FIRE_LOOP",
    channel = CHAN_WEAPON,
    volume = 1.0,
    level = 90,
    sound = "lfs/bf109/weapons/nose_loop.wav"
} )

sound.Add( {
    name = "BF109_FIRE_LASTSHOT",
    channel = CHAN_WEAPON,
    volume = 1.0,
    level = 90,
    sound = "lfs/bf109/weapons/nose_lastshot.mp3"
} )

sound.Add( {
    name = "BF109_FIRE2_LOOP",
    channel = CHAN_ITEM,
    volume = 1.0,
    level = 90,
    sound = "lfs/bf109/weapons/wing_loop.wav"
} )

sound.Add( {
    name = "BF109_FIRE2_LASTSHOT",
    channel = CHAN_ITEM,
    volume = 1.0,
    level = 90,
    sound = "lfs/bf109/weapons/wing_lastshot.mp3"
} )

sound.Add( {
    name = "LFS_BF109_RPM4",
    channel = CHAN_STATIC,
    volume = 0.8,
    level = 125,
    sound = "^lfs/bf109/rpm_4.wav"
} )

sound.Add( {
    name = "LFS_BF109_DIST",
    channel = CHAN_STATIC,
    volume = 1,
    level = 125,
    sound = "^lfs/bf109/dist.wav"
} )