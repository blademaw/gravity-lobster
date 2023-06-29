// File to try gravity simulator

import gl
import color
import vec

// constants
let G: float = 6.67430 * pow(10., -11.)

// universe types
class Body:
    name     : string
    mass     : float
    radius   : float
    pos      : xy_f = xy_0
    velocity : xy_f = xy_0
    accel    : xy_f = xy_0
    visible  : bool = true
    color    : color       // lobster-like colors

    // get the distance between this body and another
    def dist(b: Body) -> float:
        return sqrt(
            pow((b.pos.x - pos.x), 2.) + pow((b.pos.y - pos.y), 2.)
        )

    // get the force on this body from another body
    def forceFrom(b: Body) -> xy_f:
        let distance = dist(b)
        let force = G * mass * b.mass / (distance*distance)
        let diffs = b.pos - pos

        return force * (diffs / distance)

struct Universe:
    bodies : [Body]
    width  : float

    // get the net force acting on a body (in the universe)
    def netForceOn(b: Body) -> xy_f:
        var netForce: xy_f = xy_0
        for(bodies) b2:
            if b2 != b:
                netForce += b.forceFrom(b2)

        return netForce

    // get the next acceleration value for a body
    def nextAccel(b: Body) -> xy_f:
        // print netForceOn(b) / b.mass
        return netForceOn(b) / b.mass

    // get the next velocity for a body after a change in time
    def nextVelocity(b: Body, t: float) -> xy_f:
        // print b.velocity + b.accel * t
        return b.velocity + b.accel * t

    // get the next position for a body after a change in time
    def nextPos(b: Body, t: float) -> xy_f:
        return b.pos + b.velocity*t + .5*b.accel*(t*t)

    // get the next universe after a time
    def next(t: float) -> Universe:
        let newUniverse = Universe {
            bodies : deepcopy(bodies, 2), // not sure how deep to do this
            width  : width
        }
        // print(newUniverse.bodies[1])

        for(bodies) b, i:
            newUniverse.bodies[i].accel    = nextAccel(b)
            newUniverse.bodies[i].velocity = nextVelocity(b, t)
            newUniverse.bodies[i].pos      = nextPos(b, t)

        return newUniverse


    // get the next universe after a time and ticks
    def tick(timestep: float, repeats: int) -> Universe:
        var finalUniverse = next(timestep)
        for(repeats):
            finalUniverse = finalUniverse.next(timestep)
        return finalUniverse

    
    // draw the universe
    def draw():
        let units = float(gl_window_size()) / xy_f { width, width }
        gl_scale(units):
            for(bodies) b:
                gl_translate(b.pos):
                    gl_color(b.color)
                    let scale_amount = if not b.visible: 10. else: 1.
                    gl_circle(b.radius*scale_amount, 60)



// Jupiter and its moons
let jupiter = Body {
    name : "Jupiter",
    mass : 1.898 * pow(10., 27.),
    radius : 71000000.,
    pos : xy_f { 2000000000., 2000000000. },
    velocity : xy_f { 0., 0. },
    color : from_srgb(color { 223., 227., 202., 1. })
}

let io = Body {
    name : "Io",
    mass : 8.9319 * pow(10., 22.),
    radius : 1821000.,
    pos : xy_f { 2000000000.-421600000., 2000000000. },
    velocity : xy_f { 0., -17320. },
    visible : false,
    color : from_srgb(color { 249., 249., 165., 1. })
}

let europa = Body {
    name : "Europa",
    mass : 4.7998 * pow(10., 22.),
    radius : 156900.,
    pos : xy_f { 2000000000., 2000000000.+670900000. },
    velocity : xy_f { -13740., 0. },
    visible : false,
    color : from_srgb(color { 132., 83., 52., 1. })
}

let ganymede = Body {
    name : "Ganymede",
    mass : 1.4819 * pow(10., 23.),
    radius : 2631000.,
    pos : xy_f { 2000000000.+1070400000., 2000000000. },
    velocity : xy_f { 0., 10870. },
    visible : false,
    color : from_srgb(color { 76., 0., 152., 1. })
}

let callisto = Body {
    name : "Callisto",
    mass : 1.0759 * pow(10., 23.),
    radius : 2410000.,
    pos : xy_f { 2000000000., 2000000000.-1882700000. },
    velocity : xy_f { 8200., 0. },
    visible : false,
    color : from_srgb(color { 0., 153., 76., 1. })
}

var universe = Universe {
    bodies : [jupiter, io, europa, ganymede, callisto],
    width : 4000000000.
}


// Graphics
let t_fidelity: float = 60.
// let t_tick    : float = 3600.
// let reps      : int   = int(t_tick / t_fidelity)
let reps: int = 10
let WINDOW_WIDTH = 500
var play = true
fatal(gl_window("Gravity Simulator", WINDOW_WIDTH, WINDOW_WIDTH))

// start the graphics
while gl_frame():
    if gl_button("escape") or gl_button("q"): return nil
    gl_clear(color_black)

    // draw the universe
    universe.draw()
    if play:
        universe = universe.tick(t_fidelity, reps)

    if gl_button("space") == 1:
        play = not play

    // for now, user ticks time with t = 1
    // if gl_button("right") >= 1:
    //     universe = universe.tick(t_fidelity, reps)
