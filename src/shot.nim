# shot.nim
# Copyright (c) 2017 Vladar
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Vladar vladar4@gmail.com

import
  nimgame2 / [
    assets,
    draw,
    entity,
    nimgame,
    procgraphic,
    texturegraphic,
    types,
    utils
  ],
  data


type
  Shot* = ref object of Entity


const
  ShotColor = 0xFF0000FF'u32
  ShotRad = 1.0 # shot radius
  ShotSpeed = (0.0, -150.0) # shot speed for the 0 degrees direction


proc drawShot*(graphic: ProcGraphic,
               pos: Coord,
               angle: Angle,
               scale: Scale,
               center: Coord,
               flip: Flip,
               region: Rect) =
  discard circle(pos, ShotRad, ShotColor, DrawMode.filled)


proc init*(shot: Shot, pos: Coord, angle: Angle) =
  shot.initEntity()
  shot.tags.add("shot")
  shot.graphic = newProcGraphic()
  shot.physics = defaultPhysics
  shot.collider = shot.newCircleCollider((0, 0), ShotRad)
  shot.collider.tags.add("rock") # check collisions "shot - rock" only
  ProcGraphic(shot.graphic).procedure = drawShot
  shot.pos = pos + rotate((0.0, - gfxData["ship"].dim.h / 2), angle)
  shot.vel = rotate(ShotSpeed, angle)


proc newShot*(pos: Coord, angle: Angle): Shot =
  new result
  result.init(pos, angle)


method update*(shot: Shot, elapsed: float) =
  shot.updateEntity(elapsed)
  # check screen limits
  if shot.pos.x < - ShotRad or
     shot.pos.x > game.size.w.float + ShotRad or
     shot.pos.y < - ShotRad or
     shot.pos.y > game.size.h.float + ShotRad:
    shot.dead = true


method onCollide*(shot: Shot, target: Entity) =
  if "rock" in target.tags:
    shot.dead = true

