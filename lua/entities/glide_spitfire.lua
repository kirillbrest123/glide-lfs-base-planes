-- Example car class
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_plane"
ENT.PrintName = "Spitfire"
ENT.Author = ".kkrill"

ENT.GlideCategory = "ClassicPlanes"
ENT.ChassisModel = "models/blu/spitfire.mdl"
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

    ENT.StartSoundPath = "lfs/spitfire/start.mp3"
    ENT.DistantSoundPath = "LFS_SPITFIRE_DIST"

    ENT.EngineSoundPath = "LFS_SPITFIRE_RPM4"
    ENT.EngineSoundLevel = 90
    ENT.EngineSoundVolume = 0.6
    ENT.EngineSoundMinPitch = 80
    ENT.EngineSoundMaxPitch = 120

    ENT.WeaponInfo = {
        { name = "#glide.weapons.explosive_cannon", icon = "glide/icons/bullets.png" },
    }

    ENT.CrosshairInfo = {
        { iconType = "dot", traceOrigin = Vector( 136.19, 0, 53.7) },
    }

    ENT.ExhaustPositions = {
        Vector( 128.47, 16.7, 79 ),
        Vector( 117.01, 17.6, 78.93 ),
        Vector( 105.68, 17.49, 79.16 ),
        Vector( 128.47, -16.7, 79 ),
        Vector( 117.01, -17.6, 78.93 ),
        Vector( 105.68, -17.49, 79.16 ),
    }

    ENT.StrobeLights = {

    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 128, 0, 88 ), angle = Angle( 90, 0, 50 ), scale = 0.5 },
    }

    function ENT:OnActivateMisc()
        BaseClass.OnActivateMisc( self )

        self.rotorBone = self:LookupBone( "Rotor" )
        self.rotorAngle = Angle()
        self.rotorIsSpinningFast = false
        self.rudderBone = self:LookupBone( "Rudder" )
        self.elevatorBone = self:LookupBone( "Elevator" )
        self.aileronRBone = self:LookupBone( "Aileron_R" )
        self.aileronLBone = self:LookupBone( "Aileron_L" )
    end

    local ang = Angle()

    function ENT:OnUpdateAnimations()
        if not self.rudderBone then return end

        local isSpinningFast =  self:GetPower() > 0.65

        if self.isSpinningFast != isSpinningFast then
            self.isSpinningFast = isSpinningFast
            self:SetBodygroup( 1, isSpinningFast and 1 or 0 )
        end

        local dt = FrameTime()
        self.rotorAngle.p = ( self.rotorAngle.p + 5000 * self:GetPower() * dt ) % 360

        self:ManipulateBoneAngles( self.rotorBone, self.rotorAngle )

        ang[1] = 0
        ang[2] = 0
        ang[3] = self:GetElevator() * 25

        self:ManipulateBoneAngles( self.elevatorBone, ang )

        ang[2] = self:GetRudder() * 15
        ang[1] = 0
        ang[3] = 0

        self:ManipulateBoneAngles( self.rudderBone, ang )

        local aileron = self:GetAileron()

        ang[1] = 0
        ang[3] = aileron * -25
        ang[2] = 0

        self:ManipulateBoneAngles( self.aileronRBone, ang )

        ang[1] = 0
        ang[3] = aileron * 25
        ang[2] = 0

        self:ManipulateBoneAngles( self.aileronLBone, ang )

        self:AnimateLandingGear()
    end

    local pos = Vector( 0, 0, 0 )

    -- NOTE: i have no idea if the name LandingGearAngle is accurate here, but if you have any other suggestions about
    -- what SMRG and SMLG could mean, i would love to hear them
    ENT.LandingGearAngle = 0
    function ENT:AnimateLandingGear()
        self.LandingGearAngle = self.LandingGearAngle + ( 90 * ( 1 - self:GetLandingGearExtend() ) - self.LandingGearAngle ) * FrameTime() * 8 or 0

        local landingGearAngle = self.LandingGearAngle

        ang[1] = -landingGearAngle
        ang[2] = -landingGearAngle * 0.335
        ang[3] = 0

        self:ManipulateBoneAngles( 8, ang )

        pos[1] = landingGearAngle * 0.022
        pos[2] = -landingGearAngle * 0.005
        pos[3] = 0

        self:ManipulateBonePosition( 8, pos )

        ang[1] = landingGearAngle
        ang[2] = landingGearAngle * 0.335
        ang[3] = 0

        self:ManipulateBoneAngles( 7, ang )

        pos[1] = -landingGearAngle * 0.022
        pos[2] = -landingGearAngle * 0.005
        pos[3] = 0

        self:ManipulateBonePosition( 7, pos )

        ang[1] = 0
        ang[2] = 0
        ang[3] = 45 - landingGearAngle / 2

        self:ManipulateBoneAngles( 4, ang )
        self:ManipulateBoneAngles( 5, ang )
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
    ENT.ChassisMass = 1200
    ENT.SpawnPositionOffset = Vector( 0, 0, 40 )

    ENT.ExplosionGibs = {
        "models/blu/spitfire.mdl"
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

    ENT.WeaponSlots = {
        { maxAmmo = 0, fireRate = 0.03, replenishDelay = 0, ammoType = "machine_gun" },
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 20, 0, 57 ), Angle( 0, -90, 12 ), Vector( -53.2, 83.6, 29.6 ), true )

        self.wheelParams.suspensionLength = 38
        self.wheelParams.springStrength = 1500
        self.wheelParams.springDamper = 6000
        self.wheelParams.brakePower = 2000
        self.wheelParams.sideTractionMultiplier = 250

        -- Front left
        self:CreateWheel( Vector( 80.28, 45, 48 ), {
            radius = 10
        } )

        -- Front right
        self:CreateWheel( Vector( 80.28, -45, 48 ), {
            radius = 10
        } )

        -- Rear
        self:CreateWheel( Vector( -150.29, 0, 101 ), {
            radius = 8,
            steerMultiplier = -1
        } )

        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end
    end

    function ENT:GetSpawnColor()
        return Color( 255, 255, 255 )
    end

    ENT.Mirror = 1

    function ENT:OnWeaponFire( weapon )
        local attacker = self:GetSeatDriver( 1 )

        if weapon.ammoType == "machine_gun" then
            self:SetFiringGun( true )

            self:FireBullet( {
                pos = self:LocalToWorld( Vector( 136.19, 74.97 * self.Mirror, 53.7) ),
                ang = self:LocalToWorldAngles( Angle( 0, -0.6 * self.Mirror, 0 ) ),
                attacker = attacker,
                spread = 0.018,
                damage = 26,
            } )

            self.Mirror = -self.Mirror
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

sound.Add( {
    name = "SPITFIRE_FIRE_LOOP",
    channel = CHAN_WEAPON,
    volume = 1.0,
    level = 90,
    sound = "lfs/spitfire/weapons/wing_loop.wav"
} )

sound.Add( {
    name = "SPITFIRE_FIRE_LASTSHOT",
    channel = CHAN_WEAPON,
    volume = 1.0,
    level = 90,
    sound = "lfs/spitfire/weapons/wing_lastshot.mp3"
} )

sound.Add( {
    name = "LFS_SPITFIRE_RPM4",
    channel = CHAN_STATIC,
    volume = 0.8,
    level = 125,
    sound = "^lfs/spitfire/rpm_4.wav"
} )

sound.Add( {
    name = "LFS_SPITFIRE_DIST",
    channel = CHAN_STATIC,
    volume = 1,
    level = 125,
    sound = "^lfs/spitfire/dist.wav"
} )