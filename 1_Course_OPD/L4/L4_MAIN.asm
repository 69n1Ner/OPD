org 0x461
start: cla
  st res
  ld x
  dec
  push
  call $pp
  pop
  sub res
  st res
  ld y
  push
  call $pp
  pop
  sub res
  st res
  ld z
  push
  call $pp
  pop
  sub res
  st res
  hlt
z: word 0x0bbb
y: word 0xdead
x: word 0x1234
res: word 0x0000

org 0x689
; подпрограмма
pp:
  ld &1 
  bpl plus
  cmp n1
  bmi plus
  jump minus
plus:  add &1
  add &1
  add &1
  add n2
  jump ppend
minus:  ld n1
ppend:
  st &1
  ret
n1: word 0x100
n2: word 0xFFFF