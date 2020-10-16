using Luxor

begin
    Drawing(142, 56, "logo.svg")
    origin()
    fontsize(50)
    fontface("Arial Rounded MT Bold")
    translate(-71, 12)
    text("\"{:", halign=:left, valign=:baseline)
    @show textpath("\"{:")
    translate(79, -10)
    juliacircles(11)
    translate(18, 10)
    text("}\"", halign=:left, valign=:baseline)
    @show textextents("}\"")
    # textextents
    finish()
end