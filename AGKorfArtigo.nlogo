breed [presas presa]
breed [predadores predador]
globals[
 xP
 yP
 xC1
 yC1
 xC2
 yC2
 xC3
 yC3
 xC4
 yC4
 equacao
]

predadores-own [
  localPresa ;Variável para armazenar a posição da pesa se estiver dentro do campo de visão ou se algum predador comunicar.
  manhattanPresa ; Armazena a primeira parte da equação, distância de manhattan do predador em relação a presa.
  manhattanPresaAG
  manhattanPresaTeste
  manhattanPredadores ; Armazena a segunda parte da equação, a multiplicação de k com o somatório das distâncias de manhattan dos predadores.
  manhattanPredadorAG
  resultExtKorf ; Lista que armazena os 8 resultados referente as 8 posições.
  perseguindo?
]

to setup
  clear-all
  ask patches [
    set pcolor white
  ]
  create-presas 1 [
    setxy 15 15
    set color yellow
  ]
  create-predadores 4 [
    setxy random-pxcor random-pycor
    set color red
    ;;pen-down
  ]
  ask turtles [
    set label who
    set label-color black
  ]
  reset-ticks
end

to go
  if not any? presas[
    stop
  ]
  if ticks > 1000[
    stop
  ]

  ask presas [
    ifelse aleatorio?
      [andarAleatorio]
      [fugir]
  ]

  ask predadores [
    penalizado
    pegar-posicoes
    ;manhattan1
    ;manhattan1AG
    ;manhattan1AGTeste ;CORRETO
    manhattan2
    manhattan2AG
    ;extendKorf
    ;extendKorfAG
    ;;capturar
    calcula-distancias
  ]
  ler-arquivo-c
  ;ler-arquivo
  ;dividir-equacao
  ;dividir-string
  tick
end

to andarAleatorio
  if random 100 < 90
    [
      right random 360
      forward 1
    ]
end

to fugir
  if random 100 < 90
  [
    face min-one-of predadores [distance myself]
    rt 180
    fd 1
  ]
end

to capturar
  let prey one-of presas-here
  if prey != nobody
    [
      ask presas [
        die
      ]
    ]
end

to penalizado
   let teste [who] of predadores in-radius 1.5
   if length teste >= 2
   [
     move-to one-of patches
   ]
end

;;#############################################################################################
;;########################################     INICIO     #####################################
;;#############################################################################################


to-report ver-presa
  let localPres [list pxcor pycor ] of presas in-radius fov
  report localPres
end

to-report ver-predadores
  let quem [who] of presas in-radius foc
  report quem
end


;;######### Pegar posição dos agentes e salva em variáveis ###############################

to pegar-posicoes
  let localdaPresa [list pxcor pycor ] of presa 0
  set xP item 0 localdaPresa
  set yP item 1 localdaPresa

  let localdoC1 [list pxcor pycor ] of predador 1
  set xC1 item 0 localdoC1
  set yC1 item 1 localdoC1

  let localdoC2 [list pxcor pycor ] of predador 2
  set xC2 item 0 localdoC2
  set yC2 item 1 localdoC2

  let localdoC3 [list pxcor pycor ] of predador 3
  set xC3 item 0 localdoC3
  set yC3 item 1 localdoC3

  let localdoC4 [list pxcor pycor ] of predador 4
  set xC4 item 0 localdoC4
  set yC4 item 1 localdoC4
end

;;#############################################################################################
;;########################################     NOVO     ########################################
;;#############################################################################################


;to-report xCa [xCacador]
;  report xCacador
;end;

;to-report yCa [yCacador]
;  report yCacador
;end


;to manhattan1AG
;  let distanciaAG 0
;  set manhattanPresaAG []
;  ;;let xC xca xcor
;  ;;let yC yca ycor
;    foreach [0 45 90 135 180 225 270 315] [
;      ask patch-at-heading-and-distance ? 1 [
;        set distanciaAG abs (xP - pxcor) + abs (yP - pycor)
;      ]
;      set manhattanPresaAG lput distanciaAG manhattanPresaAG
;    ]
;    show "ManhattanPresaAG"
;    show manhattanPresaAG
;end


to manhattan1AGTeste
  ifelse ver-presa = []
  [
    set manhattanPresaTeste [0 0 0 0 0 0 0 0]
  ]
  [
    let xCi pxcor
    let yCi pycor
    let distPolar 0
    set manhattanPresaTeste []
    face turtle 0
    let dir heading

    ;;show [ distance patch xCi yCi ] of patch xP yP

    foreach [0 45 90 135 180 225 270 315] [




      ask patch-at-heading-and-distance ? 1 [
        let hipo distance presa 0
        set distPolar (abs catadj hipo dir) + (abs catop hipo dir)
      ]
      set manhattanPresaTeste lput distPolar manhattanPresaTeste

    ]
    ;;show ManhattanPresa
    set perseguindo? true
    ;show "##################### estou vendo a presa ####################################"
  ]
  show "Manhattan Presa Teste"
  show manhattanPresaTeste
end






;#################################################################################################################################


to manhattan2AG
  let distanciaAG 0
  let lista1 [0 0 0 0 0 0 0 0]
  let lista2 [0 0 0 0 0 0 0 0]
  let lista3 [0 0 0 0 0 0 0 0]
  set manhattanPredadorAG []
  let quem [who] of predadores in-radius foc

  ;show quem

  foreach quem [
    if (? != who)
    [
      let PC [list xcor ycor ] of predador ?
      let xPC item 0 PC
      let yPC item 1 PC

      foreach [0 45 90 135 180 225 270 315] [
        ask patch-at-heading-and-distance ? 1 [
          set distanciaAG abs (xPC - pxcor) + abs (yPC - pycor)
        ]
        set manhattanPredadorAG lput distanciaAG manhattanPredadorAG
      ];end foreach [0 45 90 135 180 225 270 315] [
    ];end if(? != who)
  ];end foreach quem

  if length manhattanPredadorAG > 0
  [set lista1 sublist manhattanPredadorAG 0 8]
  if length manhattanPredadorAG > 8
  [set lista2 sublist manhattanPredadorAG 8 16]
  if length manhattanPredadorAG > 16
  [set lista3 sublist manhattanPredadorAG 16 24]

  let soma (map [?1 + ?2 + ?3] lista1 lista2 lista3)


  set manhattanPredadorAG (map [? * k] soma )
  show "M PredadorAG"
  show manhattanPredadorAG
end

to extendKorfAG
  set resultExtKorf (map [?1 - ?2 ] manhattanPresaAG manhattanPredadorAG)
  ifelse resultExtKorf = [0 0 0 0 0 0 0 0]
  [
    right random 360
    forward 1
  ]
  [
    escolhaDirecao
  ]
end

to escolhaDirecao
  let listaDirecao melhorPosicao [0 45 90 135 180 225 270 315]
  let direcao item listaDirecao [0 45 90 135 180 225 270 315]
  set heading direcao
  fd 1
end

to-report melhorPosicao [my-list]
  ;show my-list
  ;show resultExtKorf
  let listaMenor menorDistancia resultExtKorf
  ;show  melhorp
  let menorPosicao first listaMenor ;Armazena a posição onde esta a melhor direcao para seguir Ex lista [0 45 90 135 180 225 270 315] posicao 3 = 135º
  report menorPosicao
end

to-report menorDistancia [my-list]
  let min-value min my-list
  let indices n-values (length my-list) [?]
  let indices-and-values map [list ? item ? my-list] indices
  report map [first ?] filter [item 1 ? = min-value] indices-and-values
end



;;#############################################################################################
;;########################################     FIM     ########################################
;;#############################################################################################


to desenhar-grade
  crt world-width [
    set ycor min-pycor
    set xcor who + .5
    set color 2
    set heading 0
    pd
    fd world-height
    die
  ]
  crt world-height [
    set xcor min-pxcor
    set ycor who + .5
    set color 2
    set heading 90
    pd
    fd world-width
    die
  ]
end






to calcula-distancias
  if(who = 1)
  [
  let dist1ppresa [distance myself] of presa 0
  ;show dist1ppresa
  let somatoriodist1 [distance myself] of predador 1 + [distance myself] of predador 2 + [distance myself] of predador 3 + [distance myself] of predador 4
  ;show [distance myself] of predador 1 + [distance myself] of predador 2 + [distance myself] of predador 3 + [distance myself] of predador 4
  ]
  if(who = 2)
  [
    let dist2ppresa [distance myself] of presa 0
    ;show dist2ppresa
    let somatoriodist2 [distance myself] of predador 1 + [distance myself] of predador 2 + [distance myself] of predador 3 + [distance myself] of predador 4
  ]
  if(who = 3)
  [
    let dist3ppresa [distance myself] of presa 0
    ;show dist3ppresa
    let somatoriodist3 [distance myself] of predador 1 + [distance myself] of predador 2 + [distance myself] of predador 3 + [distance myself] of predador 4
  ]
  if(who = 4)
  [
    let dist4ppresa [distance myself] of presa 0
    ;show dist4ppresa
    let somatoriodist4 [distance myself] of predador 1 + [distance myself] of predador 2 + [distance myself] of predador 3 + [distance myself] of predador 4
  ]
end


to-report string-to-list [ s ]
  report ifelse-value empty? s
    [ [] ]
    [ fput first s string-to-list but-first s ]
end

to ler-arquivo-c
  file-open "melhor3.txt"
  set equacao []
  while [not file-at-end? ] [
    set equacao file-read-line
    set equacao string-to-list equacao
    dividir-equacao

  ]
  file-close
end


to-report trocar [vantigo vnovo lista]
  while [ member? vantigo lista ] [
    let index position vantigo lista
    set lista replace-item index lista vnovo
  ]
  report lista
end

to-report realizar-troca [lista]
  set lista trocar "A" "xP" lista
  set lista trocar "B" "yP" lista
  set lista trocar "C" "xC1" lista
  set lista trocar "D" "xC2" lista
  set lista trocar "E" "xC3" lista
  set lista trocar "F" "xC4" lista
  set lista trocar "G" "yC1" lista
  set lista trocar "H" "yC2" lista
  set lista trocar "I" "yC3" lista
  set lista trocar "J" "yC4" lista
  set lista trocar "K" "k" lista
  set lista trocar "L" "+" lista
  set lista trocar "M" "-" lista
  set lista trocar "N" "*" lista
  set lista trocar "O" "/" lista
  set lista trocar "P" "(" lista
  set lista trocar "Q" ")" lista
  report lista
end

to dividir-equacao
  let manhattanP1 sublist equacao 0 7
  let manhattanP2 sublist equacao 11 34
  ;show realizar-troca manhattanP1
  ;show realizar-troca manhattanP2
end



;###################################################################################################################
;###################################################################################################################
;;########################################     ANTIGO     ##########################################################
;;##################################################################################################################
;###################################################################################################################

;;######### Cáculo dos catetos, requisito para Coordenada Polar ###############################

to-report catadj [hipo lado]
  report (hipo * cos lado)
end

to-report catop [hipo lado]
  report (hipo * sin lado)
end

;;######### Cáculo da primeira parte da esquação do Extend Korf ###############################
;;######### Saída de manhattanPresa

to manhattan1
  ifelse ver-presa = []
  [
    set manhattanPresa [0 0 0 0 0 0 0 0]
    set perseguindo? false
  ]
  [
    let distPolar 0
    set manhattanPresa []
    face turtle 0
    let dir heading
    foreach [0 45 90 135 180 225 270 315] [
      ask patch-at-heading-and-distance ? 1 [
        let hipo distance presa 0
        set distPolar (abs catadj hipo dir) + (abs catop hipo dir)
      ]
      set manhattanPresa lput distPolar manhattanPresa

    ]
    ;;show ManhattanPresa
    set perseguindo? true
    ;show "##################### estou vendo a presa ####################################"
  ]
  show "Manhattan Presa Nornal"
  show manhattanPresa
end


;;######### Cáculo da segunda parte da esquação do Extend Korf ################################
;;######### saída de manhattanPredadores

to manhattan2
  if not any? presas[
    stop
  ]
  let distancia 0
  let lista1 [0 0 0 0 0 0 0 0]
  let lista2 [0 0 0 0 0 0 0 0]
  let lista3 [0 0 0 0 0 0 0 0]
  let manhattanPredador []

  let mensagemLocalPresa [list pxcor pycor] of presa 0

  let pp [list pxcor pycor ] of predadores in-radius foc
  let quem [who] of predadores in-radius foc
  let comunicados filter [? != who] quem  ;Pega a lista de quem ele enxerga e filtra para retirar o valor dele mesmo. ? = elelento e testa todos

  foreach comunicados [
    ask predador ? [
      set localPresa mensagemLocalPresa
    ]
  ]

  foreach pp [
    let ppx item 0 ?
    let ppy item 1 ?
    ifelse (pxcor = ppx) and (pycor = ppy)
    [
      ;;show "Sou eu"
    ]
    [
      foreach [0 45 90 135 180 225 270 315] [
        ask patch-at-heading-and-distance ? 1 [
          ;;show mensagemLocalPresa

          set distancia abs (pxcor - ppx) + abs (pycor - ppy) ;;VALENDO
        ]
        set manhattanPredador lput distancia manhattanPredador
      ]
    ]
  ]

  if length manhattanPredador > 0
  [set lista1 sublist manhattanPredador 0 8]
  if length manhattanPredador > 8
  [set lista2 sublist manhattanPredador 8 16]
  if length manhattanPredador > 16
  [set lista3 sublist manhattanPredador 16 24]

  ;show lista1
  ;show lista2
  ;show lista3

  let soma (map [?1 + ?2 + ?3] lista1 lista2 lista3)

  ;show soma

  set manhattanPredadores (map [? * k] soma )
  show "MPredador Normal"
  show manhattanPredadores

end



to extendKorf
  set resultExtKorf (map [?1 - ?2 ] manhattanPresa manhattanPredadores)
  ;show "#################"
  ;show manhattanPresa
  ;show manhattanPredadores
  ;show resultExtKorf

  ifelse resultExtKorf = [0 0 0 0 0 0 0 0]
  [
    right random 360
    forward 1
    ;show "estou perdido"
  ]
  [
   ; show "estou vendo alguém"
    escolhaDirecao

  ]

end




to ler-arquivo
  file-open "melhor3.txt"
  set equacao []
  while [not file-at-end? ] [
    set equacao file-read-line
    set equacao string-to-list equacao
    dividir-equacao

  ]
  file-close
end







to dividir-string
  let i 0
  let mylist []
  while [i <= length equacao]
  [
    let local position " " equacao

    let pedaco substring equacao i local
    set equacao substring equacao local length equacao
    set mylist lput pedaco mylist
    ;;fput first s string-to-list but-first s

  ]
  show "Minha lista"
    show mylist
    show "Equacao"
    show equacao
end

  ;if (not member? 1 quem)
  ;[
  ;  set xC1 0
  ;  set yC1 0
  ;]
  ;if (not member? 2 quem)
  ;[
  ;  set xC2 0
  ;  set yC2 0
  ;]
  ;if (not member? 3 quem)
  ;[
  ;  set xC3 0
  ;  set yC3 0
  ;]
  ;if (not member? 4 quem)
  ;[
  ;  set xC4 0
  ;  set yC4 0
  ;]




to manhattan2AGVelho
  let distanciaAG 0
  set manhattanPredadorAG []
  let quem [who] of predadores in-radius foc

  ;;let comunicados filter [? != who] quem
  ;;show comunicados




  foreach [0 45 90 135 180 225 270 315] [
      if( who = 1)
      [
        ask patch-at-heading-and-distance ? 1 [
          if (not member? 2 quem)
          [
            set distanciaAG abs (xC3 - pxcor) + abs (yC3 - pycor) + abs (xC4 - pxcor) + abs (yC4 - pycor)
          ]
          if (not member? 3 quem)
          [
            set distanciaAG abs (xC2 - pxcor) + abs (yC2 - pycor)  + abs (xC4 - pxcor) + abs (yC4 - pycor)
          ]
          if (not member? 4 quem)
          [
            set distanciaAG abs (xC2 - pxcor) + abs (yC2 - pycor) + abs (xC3 - pxcor) + abs (yC3 - pycor)
          ]
          set distanciaAG 0
        ]
      ]
      if( who = 2)
      [
        ask patch-at-heading-and-distance ? 1 [
          if (not member? 1 quem)
          [
            set distanciaAG abs (xC3 - pxcor) + abs (yC3 - pycor) + abs (xC4 - pxcor) + abs (yC4 - pycor)
          ]
          if (not member? 3 quem)
          [
            set distanciaAG abs (xC1 - pxcor) + abs (yC1 - pycor)  + abs (xC4 - pxcor) + abs (yC4 - pycor)
          ]
          if (not member? 4 quem)
          [
            set distanciaAG abs (xC1 - pxcor) + abs (yC1 - pycor) + abs (xC3 - pxcor) + abs (yC3 - pycor)
          ]
          set distanciaAG 0
        ]
      ]
      if( who = 3)
      [
        ask patch-at-heading-and-distance ? 1 [
          if (not member? 1 quem)
          [
            set distanciaAG abs (xC2 - pxcor) + abs (yC2 - pycor) + abs (xC4 - pxcor) + abs (yC4 - pycor)
          ]
          if (not member? 2 quem)
          [
            set distanciaAG abs (xC1 - pxcor) + abs (yC1 - pycor)  + abs (xC4 - pxcor) + abs (yC4 - pycor)
          ]
          if (not member? 4 quem)
          [
            set distanciaAG abs (xC1 - pxcor) + abs (yC1 - pycor) + abs (xC2 - pxcor) + abs (yC2 - pycor)
          ]
          set distanciaAG 0
        ]
        ;ask patch-at-heading-and-distance ? 1 [
          ;set distanciaAG abs (xC1 - pxcor) + abs (yC1 - pycor) + abs (xC2 - pxcor) + abs (yC2 - pycor) + abs (xC4 - pxcor) + abs (yC4 - pycor)
        ;]
      ]
      if( who = 4)
      [
        ask patch-at-heading-and-distance ? 1 [
          set distanciaAG abs (xC1 - pxcor) + abs (yC1 - pycor) + abs (xC2 - pxcor) + abs (yC2 - pycor) + abs (xC3 - pxcor) + abs (yC3 - pycor)
        ]
      ]
      set manhattanPredadorAG lput distanciaAG manhattanPredadorAG
  ]
  ;;show manhattanPredadorAG

  set manhattanPredadorAG (map [? * k] manhattanPredadorAG )
  show "M PredadorAG"
  show manhattanPredadorAG
end
@#$#@#$#@
GRAPHICS-WINDOW
309
11
781
504
-1
-1
14.90323
1
10
1
1
1
0
1
1
1
0
30
0
30
1
1
1
ticks
30.0

BUTTON
6
35
79
68
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

BUTTON
80
35
143
68
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

BUTTON
145
35
208
68
NIL
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
9
440
210
473
Desenhar Grades
desenhar-grade
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
6
70
208
103
fov
fov
3
15
15
1
1
NIL
HORIZONTAL

SLIDER
7
106
208
139
foc
foc
3
30
15
1
1
NIL
HORIZONTAL

SWITCH
9
178
209
211
aleatorio?
aleatorio?
1
1
-1000

SLIDER
7
142
208
175
k
k
0
1
0.7
0.1
1
NIL
HORIZONTAL

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
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="1515" repetitions="250" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="foc">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="aleatorio?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fov">
      <value value="15"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="315" repetitions="250" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="foc">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="aleatorio?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fov">
      <value value="3"/>
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
