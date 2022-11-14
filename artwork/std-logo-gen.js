// SPDX-License-Identifier: GPL-3.0-or-later
import data from "./std-logo-gen.json" assert { type: "json" };
var params = data.std;

// The angle™
function th(params) {
  return 360 / params.num / 2;
}

// Unit value of Y when mapped to coordinate space with angle between axes of "th"
function tunit(params) {
  return Math.tan(th(params) * (Math.PI / 180)) * params.unit;
}

// === Nix logo specification
console.log(params);

// var params = {
//   // Central aperture diameter, in units. It does produce nice effects if animated.
//   aperture: 2,
//   // lambda height in units. fun to play with
//   length: 4,
//   // Clipping polygon diameter, in units
//   clipr: 7,
//   // number of lambdas. doesn't really work if changed in this model.
//   num: 6,
//   // Lambda thickness, also a segment size.
//   // Should affect nothing except size and gaps.
//   unit: 25,
//   // Shrinkage for each of lambdas. Basically control inverse "font weight"
//   gaps: 1,
//   // colors to use
//   colors: ["#5277C3", "#7EBAE4"],
// };

Snap.plugin(function (Snap, Element, Paper, global) {
  Paper.prototype.cRect = function (x, y) {
    return this.rect(-x / 2, -y / 2, x, y);
  };
  Paper.prototype.cUse = function (id) {
    return this.use(id).attr({ x: -500, y: -500 });
  };
});

var s = Snap("#out").attr({
  viewBox: "-500 -500 1000 1000",
});

// Draw the lambda symbol
var lambda = s.symbol(-500, -500, 1000, 1000);
{
  let ax = params.unit;
  let ay = params.length * tunit(params) * 2;
  let a = s.cRect(ax, ay).transform(
    Snap.matrix()
      .rotate(th(params))
      .translate(0, ay / 2)
  );

  let bx = ax;
  let by = tunit(params) * (params.length * 2 + 2);
  let b = s.cRect(bx, by).transform(Snap.matrix().rotate(-th(params)));

  let cx = tunit(params) * (params.length + 2);
  let cy = params.unit * params.length;
  let c = s.cRect(cx, cy).attr({ fill: "white" });

  // mask the next one from the bottom of the lambda's leg
  let n = s.cRect(bx, by).transform(
    Snap.matrix()
      .rotate(-th(params))
      .translate(tunit(params) * params.aperture, params.unit * params.aperture)
      .invert()
  );

  let mask = s.mask().toDefs();

  let g = s.group(a, b);

  mask.add(c);
  mask.add(n);
  g.attr({ mask });

  // offset each lambda
  g.transform(Snap.matrix().scale(1 - params.gaps / 10));

  lambda.add(g);
}

var lambdas = [];

function render() {
  for (let i = 0; i < params.num; i++) {
    let color = params.colors[i % params.colors.length];
    let b = s
      .cUse(lambda)
      .attr({ fill: color })
      .transform(
        Snap.matrix()
          .rotate(-th(params) * 2 * i)
          .translate(
            -tunit(params) * params.aperture,
            params.unit * params.aperture
          )
      );
    lambdas.push(b);
  }
}

let polygonMask = s.mask().toDefs();

// mask the final result with a regular polygon
{
  // copied from <MCAD/regular_shapes.scad> so customizer will work on thingiverse
  function regular_polygon(sides, radius) {
    let angles = [...Array(sides).keys()].map((i) => i * (360 / sides));
    let coords = angles.map((a) => [
      radius * Math.cos(a * (Math.PI / 180)),
      radius * Math.sin(a * (Math.PI / 180)),
    ]);
    return coords;
    s.polygon(coords);
  }

  let p = s
    .polygon(regular_polygon(params.num, params.clipr * tunit(params)))
    .attr({ fill: "white" });

  polygonMask.add(p);
}

render();

s.group(...lambdas).attr({ mask: polygonMask });
s.el("style").node.setHTML(
  "@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@1000&display=swap');"
);
s.text(0, -15, `${params.org}/`).attr({
  "text-anchor": "middle",
  "font-family": "Nunito",
  "font-size": "20px",
  "font-weight": "bold",
});
s.text(0, 15, params.repo).attr({
  "text-anchor": "middle",
  "font-family": "Nunito",
  "font-size": "30px",
  "font-weight": "bold",
});

s.click((event) => {
  let markup = s.node.outerHTML;
  let b64 = btoa(markup);
  let aEl = document.createElement("a");
  aEl.setAttribute("download", "logo.svg");
  aEl.href = "data:image/svg+xml;base64,\n" + b64;
  document.body.appendChild(aEl);
  aEl.click();
});
