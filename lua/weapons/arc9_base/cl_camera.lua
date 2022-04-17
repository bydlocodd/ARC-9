SWEP.SmoothedMagnification = 1
SWEP.FOV = 90

function SWEP:CalcView(ply, pos, ang, fov)
    if self:GetOwner():ShouldDrawLocalPlayer() then return end

    local rec = (self:GetLastRecoilTime() + 0.25) - CurTime()

    rec = rec * 3

    rec = rec * self:GetProcessedValue("RecoilKick")

    if rec > 0 then
        ang.r = ang.r + (math.sin(CurTime() * self:GetProcessedValue("RecoilKickDamping")) * rec)
    end

    fov = fov / self:GetSmoothedFOVMag()

    self.FOV = fov

    ang = ang + (self:GetCameraControl() or Angle(0, 0, 0))

    return pos, ang, fov
end

function SWEP:GetSmoothedFOVMag()
    local mag = 1
    local speed = 100

    if self:GetInSights() then
        local target = self:GetMagnification()

        mag = Lerp(math.ease.InQuint(self:GetSightAmount()), 1, target)
        -- mag = target
        speed = Lerp(self:GetSightAmount(), speed, 20)
    end

    local diff = math.abs(self.SmoothedMagnification - mag)

    self.SmoothedMagnification = math.Approach(self.SmoothedMagnification, mag, FrameTime() * diff * speed)

    return self.SmoothedMagnification
end

function SWEP:GetCameraControl()
    local camqca = self:GetProcessedValue("CamQCA")

    if !camqca then return end

    local vm = self:GetVM()

    local ang = (vm:GetAttachment(camqca) or {}).Ang

    if !ang then return end

    ang = vm:WorldToLocalAngles(ang)
    ang:Sub(self.CamOffsetAng)
    ang:Mul(self:GetProcessedValue("CamQCA_Mult") or 1)
    ang:Mul(1-(self:GetSightAmount() * 1-(self:GetProcessedValue("CamQCA_Mult_ADS") or 0.5)))

    return ang
end