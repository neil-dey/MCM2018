globals [
  counting
  y
  teacher-friend


]
breed [students student]
breed [teachers teacher]
students-own[
  num
  routine
  current-path
  i
  friends-s
  f-start-s
  fc-start-s
]
teachers-own[
  num
  linked?
  cooldown
  routine
  current-path
  i
  friends-t
  f-start-t
  fc-start-t
]
to setup
  set counting 0
  let spawns count patches with [pcolor = magenta]
  ask patches with [pcolor = magenta][
    sprout-students (num-students / spawns)[
      set color white
      set shape "bug"
      set num counting
      set counting counting + 1
      set i 0
      rt random 360
      fd sqrt random 900
    ]
  ]
  ask students
  [
    create-links-with n-of (abs(random-normal avg-friends-s friends-stdev-s)) other students
    set friends-s link-neighbors
    set y []
    ask n-of 5 patches with [pcolor = 61][
      set y lput pxcor y
      set y lput pycor y
    ]
    ask patches with [pcolor = magenta + 1][
      set y lput pxcor y
      set y lput pycor y
    ]
    set routine y
    set current-path patch (item 0 routine) (item 1 routine)
  ]
  ask patches with [pcolor = magenta][
    sprout-teachers (num-teachers / spawns)[
      set color yellow + 2
      set shape "personty"
      set num counting
      set counting counting + 1
      set i 0
      rt random 360
      fd sqrt random 900
    ]
  ]
  ask teachers with [color = yellow + 2]
  [
    create-links-with n-of (random-normal avg-friends-t friends-stdev-t) other teachers
    set friends-t link-neighbors
    set y []
    ask n-of 5 patches with [pcolor = 61][
      set y lput pxcor y
      set y lput pycor y
    ]
    ask patches with [pcolor = magenta + 1][
      set y lput pxcor y
      set y lput pycor y
    ]
    set routine y
    set current-path patch (item 0 routine) (item 1 routine)
  ]
  ask n-of num-students-infected students [
    set color red
  ]
  ask n-of num-teachers-infected teachers[
    set color orange
  ]
  reset-ticks
  ask links [die]
end

to go
  ask students[
    if fc-start-s = 0 [; timer value
      if any? friends-s in-radius interact-radius-s [
        if random-float 1 < sociability-s [
          create-links-with friends-s in-radius interact-radius-s
          ask friends-s in-radius interact-radius-s[
            set f-start-s 15
            set fc-start-s 15
          ]
          set f-start-s 15
          set fc-start-s 15
        ]
      ]
    ]
    let yy self
    ask my-links with [link-length > interact-radius-s][
      let ss 0
      ask both-ends[
        let sels self
        if(sels != yy)[
          if(is-student? sels)[
            set ss 1
          ]
        ]
      ]
      if(ss = 1)[
        die
      ]
    ]
    if f-start-s = 0[
      face current-path
      fd 1
      if current-path = patch-here [
        set i ((i + 1) mod (length routine / 2))
        set current-path patch (item (2 * i) routine) (item (2 * i + 1) routine)
      ]
    ]
    stay-start-s
  ]
  ask teachers[
    if fc-start-t = 0 [; timer value
      if any? friends-t in-radius interact-radius-t [
        if random-float 1 < sociability-t [
          create-links-with friends-t in-radius interact-radius-t
          ask friends-t in-radius interact-radius-t[
            set f-start-t 15
            set fc-start-t 15
          ]
          set f-start-t 15
          set fc-start-t 15
        ]
      ]
      if sociability-s-t > random-float 1
      [
        let ran random 3
        if count students in-radius interact-radius-t >= ran [
          create-links-with n-of ran students in-radius interact-radius-t
          set f-start-t 15
          set fc-start-t 15
        ]
      ]
    ]
    ask my-links with [link-length > interact-radius-t][
      die
    ]
    if f-start-t = 0 [
      face current-path
      fd 1
      if current-path = patch-here [
        set i ((i + 1) mod (length routine / 2))
        set current-path patch (item (2 * i) routine) (item (2 * i + 1) routine)
      ]
    ]
    stay-start-t
  ]
  ask students with [color = red][
    if random-float 1 < prob-better[
      set color blue
    ]
  ]
  ask teachers with [color = orange][
    if random-float 1 < prob-better-teachers[
      set color blue + 1
    ]
  ]
  infect
  tick
end
to spawn-location
  if mouse-down?
  [ ask patch mouse-xcor mouse-ycor [ set pcolor magenta ] ]
end
to location
  if mouse-down?
  [ ask patch mouse-xcor mouse-ycor [ set pcolor 61 ] ]
end
to infect
  ask students with [count link-neighbors != 0 and (color != blue)]
  [
    if any? link-neighbors with [color = red or color = orange]
    [
      if 1 - (1 - p-inf-s) ^ ((count link-neighbors with [color = red or color = orange])) > random-float 1 [
        set color red
      ]
    ]
  ]
  ask teachers with [count link-neighbors != 0 and (color != blue + 1)]
  [
    if any? link-neighbors with [color = red or color = orange]
    [
      if 1 - (1 - p-inf-t) ^ ((count link-neighbors with [color = red or color = orange])) > random-float 1 [
        set color orange
      ]
    ]
  ]
end


to stay-start-s

  ifelse f-start-s = 0
  [
      ;Continue - move
    stay-cstart-s
  ]
  [
    set f-start-s f-start-s - 1 ;decrement-timer
  ]

end

to stay-start-t

  ifelse f-start-t = 0
  [
      ;Continue - move
    stay-cstart-t
  ]
  [
    set f-start-t f-start-t - 1   ;decrement-timer
  ]

end

to stay-cstart-s
  ifelse fc-start-s = 0
  [

  ]
  [
     set fc-start-s fc-start-s - 1   ;decrement-timer
  ]

end

to stay-cstart-t
  ifelse fc-start-t = 0
  [

  ]
  [
    set fc-start-t fc-start-t - 1   ;decrement-timer
  ]
end
to add-routine
  if mouse-down?
  [ ask patch mouse-xcor mouse-ycor [ set pcolor magenta + 1 ] ]
end
@#$#@#$#@
GRAPHICS-WINDOW
3
10
354
478
-1
-1
1.0
1
10
1
1
1
0
0
0
1
0
342
0
458
0
0
1
ticks
30.0

BUTTON
1014
123
1077
156
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
771
50
943
83
num-students
num-students
15
1000
680.0
20
1
NIL
HORIZONTAL

SLIDER
1143
54
1315
87
num-teachers
num-teachers
0
300
200.0
5
1
NIL
HORIZONTAL

BUTTON
1014
160
1077
193
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
771
89
946
122
num-students-infected
num-students-infected
0
100
77.0
1
1
NIL
HORIZONTAL

SLIDER
1142
91
1317
124
num-teachers-infected
num-teachers-infected
0
50
3.0
1
1
NIL
HORIZONTAL

SLIDER
961
431
1133
464
radius
radius
0
100
50.0
1
1
NIL
HORIZONTAL

BUTTON
1009
86
1083
119
NIL
location
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1014
50
1077
83
Clear
clear-all\nimport-drawing \"campusmap.png\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1142
128
1314
161
prob-better-teachers
prob-better-teachers
0
0.03
0.01
.001
1
NIL
HORIZONTAL

SLIDER
771
203
943
236
avg-friends-s
avg-friends-s
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
1148
204
1320
237
avg-friends-t
avg-friends-t
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
770
240
942
273
friends-stdev-s
friends-stdev-s
0
3
1.0
1
1
NIL
HORIZONTAL

SLIDER
1151
242
1323
275
friends-stdev-t
friends-stdev-t
0
3
1.0
1
1
NIL
HORIZONTAL

SLIDER
769
275
941
308
interact-radius-s
interact-radius-s
0
20
9.4
.1
1
NIL
HORIZONTAL

SLIDER
1150
278
1322
311
interact-radius-t
interact-radius-t
0
20
15.3
.1
1
NIL
HORIZONTAL

SLIDER
769
317
941
350
sociability-s
sociability-s
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
1150
322
1322
355
sociability-t
sociability-t
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
958
320
1130
353
sociability-s-t
sociability-s-t
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
771
162
943
195
p-inf-s
p-inf-s
0
1
0.39
.01
1
NIL
HORIZONTAL

SLIDER
1142
165
1314
198
p-inf-t
p-inf-t
0
1
0.39
.01
1
NIL
HORIZONTAL

SLIDER
771
126
943
159
prob-better
prob-better
0
0.03
0.01
.001
1
NIL
HORIZONTAL

TEXTBOX
813
26
963
44
Student Variables
11
0.0
1

TEXTBOX
1197
32
1286
50
Teacher Variables
11
0.0
1

PLOT
369
12
759
457
People
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Infected Students" 1.0 0 -2674135 true "" "plot count students with [color = red]"
"Infected Teachers" 1.0 0 -955883 true "" "plot count teachers with [color = orange]"
"Healthy Students" 1.0 0 -13345367 true "" "plot count students with [color = blue]"
"Healthy Teachers" 1.0 0 -10649926 true "" "plot count teachers with [color = blue + 1]"

BUTTON
989
203
1108
236
Spawn-Location
spawn-location
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1001
245
1097
278
NIL
add-routine
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

personty
false
0
Circle -7500403 true true 35 110 80
Polygon -7500403 true true 255 105 150 120 60 90 45 105 45 135 120 150 45 165 45 195 60 210 150 180 255 195
Rectangle -7500403 true true 79 128 94 173
Polygon -7500403 true true 75 150 135 105 165 120 90 180
Polygon -7500403 true true 75 150 135 195 165 180 90 120

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
