# preview/assembly — «як збирається AiPetFeeder» (форма 1a)

Рендери генеруються **без `--render`** (preview-режим — інакше злітають кольори).
Джерело: `bulk_hopper_module.scad` + `gallery_views.scad`.

## Що де

| Файли | Що показують | part / view |
|---|---|---|
| `step_0..9.png` | Покрокова збірка, кумулятивно (порядок §3 HANDOFF) | `part="step"` `step=N` |
| `x_base_*`, `x_tower_*`, `x_funnel_*` | Розібрані види (iso + фронт) | `part="x_base"` … |
| `full_cut_iso.png` | Вертикальний розріз вежі (housing↔cap↔cone, колесо під cap) | `part="full_cut"` |
| `food_path.png` | Шлях корму до лотка + 45° рампа задньої стінки | `view="food"` `cut="yhalf"` |
| `base_cut.png` | База в розрізі: дно, cell, пʼєдестал, лоток, відсік | `part="base_cut"` |
| `nest_check.png` | Верхня стінка housing у пазу кришки | `part="nest_check"` |
| `bayonet_iso.png` | J2 байонет, зум на locked-таб | `part="bay_zoom"` |
| `product_25/115/205/295.png` | Готовий виріб, turntable | `part="full"` |

## Перегенерувати

```sh
cd hardware/cad/openscad
# крок
xvfb-run -a openscad -o preview/assembly/step_5.png --imgsize=800,1000 --viewall --autocenter \
  --camera=0,0,0,60,0,30,0 -D 'part="step"' -D 'step=5' bulk_hopper_module.scad
# шлях корму (yhalf лишає y<0 → дивись з +Y: rz≈195)
xvfb-run -a openscad -o preview/assembly/food_path.png --imgsize=1000,820 --viewall --autocenter \
  --camera=0,0,0,76,0,195,0 -D 'view="food"' -D 'cut="yhalf"' gallery_views.scad
```

> **НЕ запускай пакет у фоні паралельно** — кілька `xvfb-run` б'ються за X-дисплей і
> тихо падають (файли не створюються). Ганяй синхронно.
>
> **`bay_zoom`** найкраще дивитись інтерактивно в OpenSCAD GUI (крутити): таби 8 мм на
> Ø160 з фіксованого ракурсу дрібні. Функціональність байонета доведена ЧИСЛОМ у `_chk.scad`
> (вхід 0 tris, дах над locked-табом 24 tris), не картинкою.
