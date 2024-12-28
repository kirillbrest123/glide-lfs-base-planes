-- Example car class
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_plane"
ENT.PrintName = "Cessna 172"
ENT.Author = ".kkrill"

ENT.GlideCategory = "ClassicPlanes"
ENT.ChassisModel = "models/blu/cessna_lfs.mdl"
ENT.MaxChassisHealth = 250

if CLIENT then
    ENT.CameraOffset = Vector( -600, 0, 150 )
    ENT.CameraCenterOffset = Vector( 0, 0, 40 )

    ENT.StartSoundPath = "lfs/cessna/start.mp3"
    ENT.DistantSoundPath = "LFS_CESSNA_DIST"

    ENT.EngineSoundPath = "LFS_CESSNA_RPM4"
    ENT.EngineSoundLevel = 90
    ENT.EngineSoundVolume = 0.6
    ENT.EngineSoundMinPitch = 80
    ENT.EngineSoundMaxPitch = 120

    ENT.ExhaustPositions = {
        Vector( 65.04, -14.93, 19.46 )
    }

    ENT.StrobeLights = {

    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 51.72, 0.65, 60 ), angle = Angle( 90, 0, 50 ), scale = 0.5 },
    }

    DEFINE_BASECLASS( "base_glide_plane" )

    function ENT:OnActivateMisc()
        BaseClass.OnActivateMisc( self )

        self.rotorBone = self:LookupBone( "rotor" )
        self.rotorAngle = Angle()
        self.rotorIsSpinningFast = false
        self.rudderBone = self:LookupBone( "rudder" )
        self.elevatorBone = self:LookupBone( "elev" )
        self.aileronRBone = self:LookupBone( "aileron_r" )
        self.aileronLBone = self:LookupBone( "aileron_l" )
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
        self.rotorAngle.r = ( self.rotorAngle.r + 5000 * self:GetPower() * dt ) % 360

        self:ManipulateBoneAngles( self.rotorBone, self.rotorAngle )

        ang[1] = 0
        ang[2] = self:GetElevator() * 25
        ang[3] = 0

        self:ManipulateBoneAngles( self.elevatorBone, ang )

        ang[1] = self:GetRudder() * 10
        ang[2] = 0
        ang[3] = 0

        self:ManipulateBoneAngles( self.rudderBone, ang )

        local aileron = self:GetAileron()

        ang[1] = 0
        ang[2] = aileron * -15
        ang[3] = 0

        self:ManipulateBoneAngles( self.aileronRBone, ang )

        ang[1] = 0
        ang[2] = aileron * 15
        ang[3] = 0

        self:ManipulateBoneAngles( self.aileronLBone, ang )
    end
end

if SERVER then
    ENT.ChassisMass = 800
    ENT.SpawnPositionOffset = Vector( 0, 0, 40 )

    ENT.ExplosionGibs = {
        "models/blu/cessna_lfs.mdl"
    }

    ENT.HasLandingGear = true

    ENT.PropModel = ""
    ENT.PropFastModel = ""

    -- Plane drag & force constants
    ENT.PlaneParams = {
        -- These drag forces only apply
        -- when flying at max. liftSpeed.
        liftAngularDrag = Vector( -5, -10, -3 ), -- (Roll, pitch, yaw)
        liftForwardDrag = 0.1,
        liftSideDrag = 3,

        liftFactor = 0.15,       -- How much of the up velocity to negate
        maxSpeed = 2000,        -- Speed limit
        liftSpeed = 1600,       -- Speed required to float
        controlSpeed = 1200,    -- Speed required to have complete control of the plane

        engineForce = 200,
        alignForce = 300,

        pitchForce = 1000,
        yawForce = 500,
        rollForce = 1200
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 4, 8, 30 ), Angle( 0, -90, 0 ), Vector( -50, 120, 0 ), true )
        self:CreateSeat( Vector( 4, -8, 30 ), Angle( 0, -90, 0 ), Vector( -50, 120, 0 ), true )
        self:CreateSeat( Vector( -35, -8, 30 ), Angle( 0, -90, 0 ), Vector( -50, 120, 0 ), true )
        self:CreateSeat( Vector( -35, 8, 30 ), Angle( 0, -90, 0 ), Vector( -50, 120, 0 ), true )

        self.wheelParams.springStrength = 1500
        self.wheelParams.springDamper = 6000
        self.wheelParams.brakePower = 2000
        self.wheelParams.sideTractionMultiplier = 250

        -- Front left
        self:CreateWheel( Vector( -14.1, 50.8, 13.7 ), {
            radius = 8
        } )

        -- Front right
        self:CreateWheel( Vector(- 14.1, -50.8, 13.7 ), {
            radius = 8
        } )

        -- Rear
        self:CreateWheel( Vector( 53.3, 0, 10 ) , {
            radius = 8
        } )

        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end

        self:GetPhysicsObject():SetInertia( Vector( 1900, 1900, 1900 ) )
    end

    function ENT:GetSpawnColor()
        return Color( 255, 255, 255 )
    end
end

sound.Add( {
    name = "LFS_CESSNA_RPM4",
    channel = CHAN_STATIC,
    volume = 1.0,
    level = 125,
    sound = "^lfs/cessna/rpm_4.wav"
} )

sound.Add( {
    name = "LFS_CESSNA_DIST",
    channel = CHAN_STATIC,
    volume = 1,
    level = 100,
    sound = "^lfs/cessna/dist.wav"
} )