;setup breeds here
breed [ind-devs ind-dev]
breed [idealists idealist]
breed [earlys early]
breed [trends trend]
breed [skeptics skeptic]
breed [holdouts holdout]

turtles-own [
  ;for making decisions

  ;action
  action

  ;guess of last round average
  fuzzy-av

  ; fixed assets
  own-production ; total productive capacity for each round
  own-os-prod-max ; a maximum level production can get to

  ;per round choice made
  own-os-prod ;level of open source production
  own-cs-prod ; level of proprietary production

  ;for reporting

  ; running total
  own-cs-code ; size/amount invested in own codebase
  own-os-code ; total contributions made to open source codebase

  ;value being acrued this round
  own-value-round
  ; running total value of firm
  own-value ; running value of firm
  ]


globals [
  ; to keep

  ;for model run

  ; keeping memory of the last round in the system to make decision
  av-last-round-os-prod ; maybe just keep this - just the one before over num_firms

  ;per round production - to store to calculate rewards
  round-os-prod ; all contributions this round to open source
  round-cs-prod ; all contributions this round to proprietary software

  ;misinformation parameter (define to do on setup)
  misinformation

  ; set a scaling parameter that allows missinformation and strategies to scale
  scaling

    ; set number of breeds
  set_ideal
  set_early
  set_trend
  set_skeptic
  set_holdout


  ;for reporting

  ;total code generated
  total-os-code ;size of the OS codebase
  total-cs-code ; size of all proprietary codebases
  total-code; size of total codebase (just so we can report)

  ;total value
  total-value ; total value of all firms

  ;potential OS code - sum all turtle max
  max-potential-os-code

]

;;;;;;;;;;;;;;;;;;;;;At setup;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  populate-firms
  create-breeds
  ask turtles [get-ready] ; give the turtles some starting parameters
  ask ind-devs [get-special]
  set-rules ;set up some global parameters
  reset-ticks
end

;;; at setup

to populate-firms
  ;function allows for us to set manually or choose market presets
  ;always create one indie dev
  create-ind-devs 1

  ifelse market-select
  [if market-shape = "D" [ ;market shaped D
    set set_ideal 1 * (num-firms / 25)
    set set_early 6 * (num-firms / 25)
    set set_trend 11 * (num-firms / 25)
    set set_skeptic 6 * (num-firms / 25)
    set set_holdout 1 * (num-firms / 25)]

  if market-shape = "C" [ ;market shaped "C"
    set set_ideal 8 * (num-firms / 25)
    set set_early 4 * (num-firms / 25)
    set set_trend 1 * (num-firms / 25)
    set set_skeptic 4 * (num-firms / 25)
    set set_holdout 8 * (num-firms / 25)]

  if market-shape = "S" [ ;market shaped "S"
    set set_ideal 9 * (num-firms / 25)
    set set_early 1 * (num-firms / 25)
    set set_trend 5 * (num-firms / 25)
    set set_skeptic 9 * (num-firms / 25)
    set set_holdout 1 * (num-firms / 25)]

  if market-shape = "S-1" [ ;market shaped "S-1"
    set set_ideal 1 * (num-firms / 25)
    set set_early 9 * (num-firms / 25)
    set set_trend 5 * (num-firms / 25)
    set set_skeptic 1 * (num-firms / 25)
    set set_holdout 9 * (num-firms / 25)]

  if market-shape = "optimistic" [ ;market shaped "optimistic"
    set set_ideal 7 * (num-firms / 25)
    set set_early 8 * (num-firms / 25)
    set set_trend 5 * (num-firms / 25)
    set set_skeptic 3 * (num-firms / 25)
    set set_holdout 2 * (num-firms / 25)]

  if market-shape = "pessimistic" [ ;market shaped "pessimistic"
    set set_ideal 3 * (num-firms / 25)
    set set_early 2 * (num-firms / 25)
    set set_trend 5 * (num-firms / 25)
    set set_skeptic 8 * (num-firms / 25)
    set set_holdout 7 * (num-firms / 25)]

   if market-shape = "balanced" [ ;market shaped "random"
    set set_ideal 5 * (num-firms / 25)
    set set_early 5 * (num-firms / 25)
    set set_trend 5 * (num-firms / 25)
    set set_skeptic 5 * (num-firms / 25)
    set set_holdout 5 * (num-firms / 25)]

  ]
  ;when button is on - create the numbers manually
  [set set_ideal num_ideal
  set set_early num_early
  set set_trend num_trend
  set set_skeptic num_skeptic
  set set_holdout num_holdout]

end

to create-breeds
  ;create breeds according to populate firm function
   create-idealists set_ideal
   create-earlys set_early
   create-trends set_trend
   create-skeptics set_skeptic
   create-holdouts set_holdout
end

to get-ready
  set own-production firm-size; set the level of production with minimum of 3 ;random 3 + random (firm-size - 3)
  set own-os-prod 0 ;
  set own-cs-prod (own-production - own-os-prod)
  set own-cs-code 0 ; size/amount invested in own codebase
  set own-os-code 0 ; total contributions made to open source codebase
  set own-value 0 ; running value of firm
  set-max-prod-vary ; set a ceiling for level of os production by breed
end

to set-max-prod-vary
  ; set a ceiling for level of os production by breed
  if breed  = idealists [set own-os-prod-max (own-production * 0.8)]
  if breed  = earlys [set own-os-prod-max (own-production * 0.6)]
  if breed  = trends [set own-os-prod-max (own-production * 0.5)]
  if breed  = skeptics [set own-os-prod-max (own-production * 0.3)]
  if breed  = holdouts [set own-os-prod-max (own-production * 0.2)]
end

to set-max-prod
  ;set no limit to production
  set own-os-prod-max own-production
end


to get-special
    set own-os-prod-max ind_dev_level
    set own-cs-prod 0
end

to set-rules
  set scaling (scaling-parameter / firm-size) ;* count turtles)
  set max-potential-os-code sum [own-os-prod-max] of turtles
  set misinformation misinf * scaling;

  set av-last-round-os-prod 0

  set total-cs-code 0
  set total-os-code 0
  set total-code 0

  set total-value 0


end


;;;;;;;;;;;;;;;;;;;;;PER GO;;;;;;;;;;;;;;;;;;;;;;

to go
  ; choose production
  ask turtles [choose-action]
  ; do production
  ask turtles [own-produce]
  total-produce
  ; calculate reward
  ask turtles [calc-own-reward]
  update-plots
  remember
  tick
end

;;;;;;;;; Choose production - ask turtles

to choose-action
; choose action based on scaled parameter

  ; first calculate an average based on misinformation - except stop it kicking off the whole thing
  ifelse av-last-round-os-prod = 0 [set fuzzy-av 0] [set fuzzy-av (av-last-round-os-prod + random-float (misinformation + (misinformation + 1)) - misinformation)] ;(misinf + (misinf + 1)) - misinf)

  ; Depending on breed -- implement a strategy that returns a 1,0,-1 which can be applied to OS

  ;Indie dev - aren't they easy!
  if breed  = ind-devs [ifelse own-os-prod = own-os-prod-max [set action 0] [set action 1]]

  ;;;;Idealists
  if breed  = idealists [ifelse fuzzy-av <= 0 [set action 0] [ifelse own-os-prod = own-os-prod-max             ;check if production is max
    [ifelse (fuzzy-av + (3 * scaling)) < own-os-prod [set action -1][set action 0]]   ;if production is max, check if you should decrease or stay the same
     [ifelse own-os-prod = 0                                              ;check if production is min
      [ifelse (fuzzy-av - (3 * scaling)) > own-os-prod [set action 1][set action 0]]  ;if production is min, check if increase otherwise same
       [ifelse (fuzzy-av + (3 * scaling)) < own-os-prod [set action -1]               ;check if should decrease, if so decrease
        [ifelse (fuzzy-av - (3 * scaling)) > own-os-prod [set action 1][set action 0] ;check if should increase, if so increase, otherwise same
  ]]]]]

  ;;;; Earlys
  if breed  = earlys [ifelse fuzzy-av <= 0 [set action 0] [ifelse own-os-prod = own-os-prod-max                ;check if production is max
    [ifelse (fuzzy-av + (1 * scaling)) < own-os-prod [set action -1][set action 0]]   ;if production is max, check if you should decrease or stay the same
     [ifelse own-os-prod = 0                                              ;check if production is min
      [ifelse (fuzzy-av - (1 * scaling)) > own-os-prod [set action 1][set action 0]]  ;if production is min, check if increase otherwise same
       [ifelse (fuzzy-av + (1 * scaling)) < own-os-prod [set action -1]               ;check if should decrease, if so decrease
        [ifelse (fuzzy-av - (1 * scaling)) > own-os-prod [set action 1][set action 0] ;check if should increase, if so increase, otherwise same
  ]]]]]

  ;;;; Trends
  if breed  = trends [ifelse fuzzy-av <= 0 [set action 0] [ifelse own-os-prod = own-os-prod-max                ;check if production is max
    [ifelse (fuzzy-av) < own-os-prod [set action -1][set action 0]]   ;if production is max, check if you should decrease or stay the same
     [ifelse own-os-prod = 0                                              ;check if production is min
      [ifelse (fuzzy-av) > own-os-prod [set action 1][set action 0]]  ;if production is min, check if increase otherwise same
       [ifelse (fuzzy-av) < own-os-prod [set action -1]               ;check if should decrease, if so decrease
        [ifelse (fuzzy-av) > own-os-prod [set action 1][set action 0] ;check if should increase, if so increase, otherwise same
  ]]]]]

  ;;;; Skeptics
  if breed  = skeptics [ifelse fuzzy-av <= 0 [set action 0] [ifelse own-os-prod = own-os-prod-max                ;check if production is max
    [ifelse (fuzzy-av - (1 * scaling)) < own-os-prod [set action -1][set action 0]]   ;if production is max, check if you should decrease or stay the same
     [ifelse own-os-prod = 0                                              ;check if production is min
      [ifelse (fuzzy-av + (1 * scaling)) > own-os-prod [set action 1][set action 0]]  ;if production is min, check if increase otherwise same
       [ifelse (fuzzy-av - (1 * scaling)) < own-os-prod [set action -1]               ;check if should decrease, if so decrease
        [ifelse (fuzzy-av + (1 * scaling)) > own-os-prod [set action 1][set action 0] ;check if should increase, if so increase, otherwise same
  ]]]]]

  ;;;; holdouts
  if breed  = holdouts [ifelse fuzzy-av <= 0 [set action 0] [ifelse own-os-prod = own-os-prod-max                ;check if production is max
    [ifelse (fuzzy-av - (3 * scaling)) < own-os-prod [set action -1][set action 0]]   ;if production is max, check if you should decrease or stay the same
     [ifelse own-os-prod = 0                                              ;check if production is min
      [ifelse (fuzzy-av + (3 * scaling)) > own-os-prod [set action 1][set action 0]]  ;if production is min, check if increase otherwise same
       [ifelse (fuzzy-av - (3 * scaling)) < own-os-prod [set action -1]               ;check if should decrease, if so decrease
        [ifelse (fuzzy-av + (3 * scaling)) > own-os-prod [set action 1][set action 0] ;check if should increase, if so increase, otherwise same
  ]]]]]


  ;carry out the action here
  set own-os-prod own-os-prod + action ;set own os production to add the decision
  if breed != ind-devs [set own-cs-prod (own-production - own-os-prod)] ;set own cs production to own production minus that

end


;;;;;;;;;;;;; do production  - ask turtles

to own-produce
  set own-cs-code own-cs-code + own-cs-prod; Increase their own codebase production by size/amount invested this round
  set own-os-code own-os-code + own-os-prod; Increase their tally of contribution to os codebase by size/amount invested this round
end

to total-produce

  ; first account for OS contributions
  set round-os-prod sum [own-os-prod] of turtles ; all contributions this round to open source
  set total-os-code total-os-code + round-os-prod ; Increase the size of the os codebase by size/amount invested this round

  ; Second account for all proprietary contribution
  set round-cs-prod sum [own-cs-prod] of turtles ; all contributions this round to proprietary software
  set total-cs-code total-cs-code + round-cs-prod ; Increase the size of the os codebase by size/amount invested this round

end

;;;;;;;;;;;;; calculate reward - ask turtles

to calc-own-reward

  ;rewrite simple payoff here
  set own-value-round ((own-cs-prod / (round-cs-prod + round-os-prod)) * own-cs-prod) + ((round-os-prod / (round-cs-prod + round-os-prod))) ;* ((firm-size * num-firms)/round-os-prod)

  set own-value own-value + own-value-round


end

to remember
  set total-value sum [own-value] of turtles
  set av-last-round-os-prod (round-os-prod / (count turtles))
end
@#$#@#$#@
GRAPHICS-WINDOW
669
322
806
460
-1
-1
3.91
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
11
10
86
43
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
10
45
73
78
setup
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
9
81
181
114
firm-size
firm-size
0
100
30.0
10
1
NIL
HORIZONTAL

PLOT
254
13
454
163
Proportion of total OS development
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"Total OS" 1.0 0 -5298144 true "" "plot (total-os-code) / \n(total-os-code + total-cs-code)\n"

PLOT
255
164
455
314
Proportion of OS this turn
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot round-os-prod / (round-os-prod + round-cs-prod)"

BUTTON
91
11
154
44
go on
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
9
116
181
149
misinf
misinf
0
5
2.0
0.1
1
NIL
HORIZONTAL

SLIDER
9
149
181
182
ind_dev_level
ind_dev_level
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
12
227
184
260
num_ideal
num_ideal
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
12
275
184
308
num_early
num_early
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
12
323
184
356
num_trend
num_trend
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
13
372
185
405
num_skeptic
num_skeptic
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
11
418
183
451
num_holdout
num_holdout
0
10
5.0
1
1
NIL
HORIZONTAL

PLOT
457
13
657
163
Proportion of total allowed OS
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot round-os-prod / max-potential-os-code"

MONITOR
656
78
769
123
Prop turn poss OS
round-os-prod / max-potential-os-code
5
1
11

MONITOR
674
14
757
59
prop total os
(total-os-code) / \n(total-os-code + total-cs-code)
5
1
11

PLOT
457
165
657
315
Proportion of total OS by category
NIL
NIL
0.0
300.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -2064490 true "" "plot (mean [own-os-prod] of idealists) / (mean [own-os-prod-max] of idealists)"
"pen-1" 1.0 0 -5825686 true "" "plot (mean [own-os-prod] of earlys) \n/ (mean [own-os-prod-max] of earlys)"
"pen-2" 1.0 0 -8630108 true "" "plot (mean [own-os-prod] of trends) \n/ (mean [own-os-prod-max] of trends)"
"pen-3" 1.0 0 -13345367 true "" "plot (mean [own-os-prod] of skeptics) \n/ (mean [own-os-prod-max] of skeptics)"
"pen-5" 1.0 0 -13791810 true "" "plot (mean [own-os-prod] of holdouts) \n/ (mean [own-os-prod-max] of holdouts)"
"pen-6" 1.0 0 -16777216 true "" "plot (mean [own-os-prod] of skeptics) \n/ (mean [own-os-prod-max] of skeptics)"

MONITOR
667
168
741
213
Total value
total-value
1
1
11

MONITOR
666
218
764
263
Value per turtle
total-value / (count turtles)
1
1
11

SWITCH
263
334
394
367
market-select
market-select
0
1
-1000

MONITOR
437
375
539
420
Number of firms
count turtles - 1
1
1
11

CHOOSER
402
327
540
372
market-shape
market-shape
"D" "C" "S" "S-1" "optimistic" "pessimistic" "balanced"
6

MONITOR
184
226
241
271
Idealist
count idealists
1
1
11

MONITOR
185
275
242
320
early
count earlys
17
1
11

MONITOR
184
323
241
368
trend
count trends
1
1
11

MONITOR
185
371
242
416
skeptics
Count skeptics
17
1
11

MONITOR
184
418
244
463
holdouts
count holdouts
17
1
11

SLIDER
9
183
181
216
scaling-parameter
scaling-parameter
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
260
381
432
414
num-firms
num-firms
25
150
150.0
25
1
NIL
HORIZONTAL

@#$#@#$#@
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

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

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
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment-1" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>(round-os-prod / max-potential-os-code)</metric>
    <metric>((total-os-code) / (total-os-code + total-cs-code))</metric>
    <metric>total-value</metric>
    <enumeratedValueSet variable="ind_dev_level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-shape">
      <value value="&quot;D&quot;"/>
      <value value="&quot;C&quot;"/>
      <value value="&quot;S&quot;"/>
      <value value="&quot;S-1&quot;"/>
      <value value="&quot;optimistic&quot;"/>
      <value value="&quot;pessimistic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_ideal">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_holdout">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-select">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_trend">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="misinf">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_early">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_skeptic">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-2" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>(round-os-prod / max-potential-os-code)</metric>
    <metric>((total-os-code) / (total-os-code + total-cs-code))</metric>
    <metric>total-value</metric>
    <steppedValueSet variable="ind_dev_level" first="0" step="1" last="10"/>
    <enumeratedValueSet variable="market-shape">
      <value value="&quot;D&quot;"/>
      <value value="&quot;C&quot;"/>
      <value value="&quot;S&quot;"/>
      <value value="&quot;S-1&quot;"/>
      <value value="&quot;optimistic&quot;"/>
      <value value="&quot;pessimistic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_ideal">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_holdout">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-select">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_trend">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="misinf">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_early">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_skeptic">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-3.1" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>(round-os-prod / max-potential-os-code)</metric>
    <metric>((total-os-code) / (total-os-code + total-cs-code))</metric>
    <metric>total-value</metric>
    <metric>total-value / num-firms</metric>
    <steppedValueSet variable="ind_dev_level" first="0" step="1" last="10"/>
    <enumeratedValueSet variable="market-shape">
      <value value="&quot;D&quot;"/>
      <value value="&quot;C&quot;"/>
      <value value="&quot;S&quot;"/>
      <value value="&quot;S-1&quot;"/>
      <value value="&quot;optimistic&quot;"/>
      <value value="&quot;pessimistic&quot;"/>
      <value value="&quot;balanced&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-size">
      <value value="10"/>
    </enumeratedValueSet>
    <steppedValueSet variable="num-firms" first="25" step="25" last="100"/>
    <enumeratedValueSet variable="market-select">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="misinf">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-1.1" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>(round-os-prod / max-potential-os-code)</metric>
    <metric>((total-os-code) / (total-os-code + total-cs-code))</metric>
    <metric>total-value</metric>
    <enumeratedValueSet variable="ind_dev_level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-shape">
      <value value="&quot;D&quot;"/>
      <value value="&quot;C&quot;"/>
      <value value="&quot;S&quot;"/>
      <value value="&quot;S-1&quot;"/>
      <value value="&quot;optimistic&quot;"/>
      <value value="&quot;pessimistic&quot;"/>
      <value value="&quot;balanced&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-firms">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-select">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="misinf">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-2.1" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>(round-os-prod / max-potential-os-code)</metric>
    <metric>((total-os-code) / (total-os-code + total-cs-code))</metric>
    <metric>total-value</metric>
    <steppedValueSet variable="ind_dev_level" first="0" step="1" last="10"/>
    <enumeratedValueSet variable="market-shape">
      <value value="&quot;D&quot;"/>
      <value value="&quot;C&quot;"/>
      <value value="&quot;S&quot;"/>
      <value value="&quot;S-1&quot;"/>
      <value value="&quot;optimistic&quot;"/>
      <value value="&quot;pessimistic&quot;"/>
      <value value="&quot;balanced&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-firms">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-select">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="misinf">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-3" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>(round-os-prod / max-potential-os-code)</metric>
    <metric>((total-os-code) / (total-os-code + total-cs-code))</metric>
    <metric>total-value</metric>
    <steppedValueSet variable="ind_dev_level" first="0" step="1" last="10"/>
    <enumeratedValueSet variable="market-shape">
      <value value="&quot;D&quot;"/>
      <value value="&quot;C&quot;"/>
      <value value="&quot;S&quot;"/>
      <value value="&quot;S-1&quot;"/>
      <value value="&quot;optimistic&quot;"/>
      <value value="&quot;pessimistic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-firms">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-select">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="misinf" first="0" step="0.5" last="2"/>
  </experiment>
  <experiment name="experiment-4.1" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>(round-os-prod / max-potential-os-code)</metric>
    <metric>((total-os-code) / (total-os-code + total-cs-code))</metric>
    <metric>total-value</metric>
    <metric>total-value / num-firms</metric>
    <enumeratedValueSet variable="ind_dev_level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-shape">
      <value value="&quot;D&quot;"/>
      <value value="&quot;C&quot;"/>
      <value value="&quot;S&quot;"/>
      <value value="&quot;S-1&quot;"/>
      <value value="&quot;optimistic&quot;"/>
      <value value="&quot;pessimistic&quot;"/>
      <value value="&quot;balanced&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-size">
      <value value="10"/>
    </enumeratedValueSet>
    <steppedValueSet variable="num-firms" first="25" step="25" last="150"/>
    <enumeratedValueSet variable="market-select">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="misinf">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-5.1" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>(round-os-prod / max-potential-os-code)</metric>
    <metric>((total-os-code) / (total-os-code + total-cs-code))</metric>
    <metric>total-value</metric>
    <metric>total-value / num-firms</metric>
    <enumeratedValueSet variable="ind_dev_level">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-shape">
      <value value="&quot;D&quot;"/>
      <value value="&quot;C&quot;"/>
      <value value="&quot;S&quot;"/>
      <value value="&quot;S-1&quot;"/>
      <value value="&quot;optimistic&quot;"/>
      <value value="&quot;pessimistic&quot;"/>
      <value value="&quot;balanced&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-size">
      <value value="10"/>
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <steppedValueSet variable="num-firms" first="25" step="25" last="150"/>
    <enumeratedValueSet variable="market-select">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="misinf">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
