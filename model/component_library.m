function out = model
%
% component_library.m
%
% Model exported on Jul 31 2024, 20:35 by COMSOL 6.1.0.252.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Users\stolf\dev\Progetto Modelli Numerici per Campi e Circuiti\MATSOL\model');

model.label('component_library.mph');

model.component.create('componentCube', true);

model.component('componentCube').geom.create('geom1', 3);

model.component.create('componentTetrahedron', true);

model.component('componentTetrahedron').geom.create('geom7', 3);

model.component.create('componentHexahedron', true);

model.component('componentHexahedron').geom.create('geom6', 3);

model.component.create('componentPyramid', true);

model.component('componentPyramid').geom.create('geom5', 3);

model.component.create('componentPrism', true);

model.component('componentPrism').geom.create('geom8', 3);

model.component.create('componentCone', true);

model.component('componentCone').geom.create('geom2', 3);

model.component.create('componentCylinder', true);

model.component('componentCylinder').geom.create('geom3', 3);

model.component.create('componentSphere', true);

model.component('componentSphere').geom.create('geom4', 3);

model.component.create('componentGeneral2D', true);

model.component('componentGeneral2D').geom.create('geom9', 2);

model.component.create('componentGeneral3D', true);

model.component('componentGeneral3D').geom.create('geom10', 3);

model.component('componentCube').label('componentCube');
model.component('componentTetrahedron').label('componentTetrahedron');
model.component('componentHexahedron').label('componentHexahedron');
model.component('componentPyramid').label('componentPyramid');
model.component('componentPrism').label('componentPrism');
model.component('componentCone').label('componentCone');
model.component('componentCylinder').label('componentCylinder');
model.component('componentSphere').label('componentSphere');
model.component('componentGeneral2D').label('componentGeneral2D');

model.component('componentGeneral2D').curvedInterior(false);

model.component('componentGeneral3D').label('componentGeneral3D');

model.component('componentGeneral3D').curvedInterior(false);

model.component('componentCube').mesh.create('mesh1');
model.component('componentCube').mesh.create('mesh14');
model.component('componentCube').mesh.create('mesh11');
model.component('componentCube').mesh.create('mesh12');
model.component('componentCube').mesh.create('mesh13');
model.component('componentCone').mesh.create('mesh2');
model.component('componentCylinder').mesh.create('mesh3');
model.component('componentSphere').mesh.create('mesh4');
model.component('componentPyramid').mesh.create('mesh5');
model.component('componentHexahedron').mesh.create('mesh6');
model.component('componentTetrahedron').mesh.create('mesh7');
model.component('componentPrism').mesh.create('mesh8');
model.component('componentGeneral2D').mesh.create('mesh9');
model.component('componentGeneral3D').mesh.create('mesh10');

model.component('componentCube').geom('geom1').label('geometryCube');
model.component('componentCube').geom('geom1').create('blk1', 'Block');
model.component('componentCube').geom('geom1').feature('blk1').label('cube');
model.component('componentCube').geom('geom1').feature('blk1').set('size', [1.5 1.5 1.5]);
model.component('componentCube').geom('geom1').run;
model.component('componentCube').geom('geom1').run('fin');
model.component('componentCone').geom('geom2').label('geometryCone');
model.component('componentCone').geom('geom2').create('cone1', 'Cone');
model.component('componentCone').geom('geom2').feature('cone1').label('cone');
model.component('componentCone').geom('geom2').feature('cone1').set('h', 2);
model.component('componentCone').geom('geom2').feature('cone1').set('specifytop', 'radius');
model.component('componentCone').geom('geom2').feature('cone1').set('rtop', '0.0');
model.component('componentCone').geom('geom2').run;
model.component('componentCone').geom('geom2').run('fin');
model.component('componentCylinder').geom('geom3').label('geometryCylinder');
model.component('componentCylinder').geom('geom3').create('cyl1', 'Cylinder');
model.component('componentCylinder').geom('geom3').feature('cyl1').label('cylinder');
model.component('componentCylinder').geom('geom3').feature('cyl1').set('h', 2);
model.component('componentCylinder').geom('geom3').run;
model.component('componentCylinder').geom('geom3').run('fin');
model.component('componentSphere').geom('geom4').label('geometrySphere');
model.component('componentSphere').geom('geom4').create('sph1', 'Sphere');
model.component('componentSphere').geom('geom4').feature('sph1').label('sphere');
model.component('componentSphere').geom('geom4').run;
model.component('componentSphere').geom('geom4').run('fin');
model.component('componentPyramid').geom('geom5').label('geometryPyramid');
model.component('componentPyramid').geom('geom5').create('pyr1', 'Pyramid');
model.component('componentPyramid').geom('geom5').feature('pyr1').label('pyramid');
model.component('componentPyramid').geom('geom5').feature('pyr1').set('h', 2);
model.component('componentPyramid').geom('geom5').feature('pyr1').set('rat', 0);
model.component('componentPyramid').geom('geom5').run;
model.component('componentPyramid').geom('geom5').run('fin');
model.component('componentHexahedron').geom('geom6').label('geometryHexahedron');
model.component('componentHexahedron').geom('geom6').create('hex1', 'Hexahedron');
model.component('componentHexahedron').geom('geom6').feature('hex1').label('hexahedron');
model.component('componentHexahedron').geom('geom6').feature('hex1').set('p', [0 0 2 2 0 0 2 2; 0 1 1 0 0 1 1 0; 0 0 0 0 1 1 1 1]);
model.component('componentHexahedron').geom('geom6').run;
model.component('componentHexahedron').geom('geom6').run('fin');
model.component('componentTetrahedron').geom('geom7').label('geometryTetrahedron');
model.component('componentTetrahedron').geom('geom7').create('tet1', 'Tetrahedron');
model.component('componentTetrahedron').geom('geom7').feature('tet1').label('tetrahedron');
model.component('componentTetrahedron').geom('geom7').feature('tet1').set('p', [0 0 1 1; 0 1 0 1; 0 0 0 1]);
model.component('componentTetrahedron').geom('geom7').run;
model.component('componentTetrahedron').geom('geom7').run('fin');
model.component('componentPrism').geom('geom8').label('geometryPrism');
model.component('componentPrism').geom('geom8').create('wp1', 'WorkPlane');
model.component('componentPrism').geom('geom8').feature('wp1').set('unite', true);
model.component('componentPrism').geom('geom8').feature('wp1').geom.create('pol1', 'Polygon');
model.component('componentPrism').geom('geom8').feature('wp1').geom.feature('pol1').set('type', 'closed');
model.component('componentPrism').geom('geom8').feature('wp1').geom.feature('pol1').set('source', 'table');
model.component('componentPrism').geom('geom8').feature('wp1').geom.feature('pol1').set('table', [0 0; 1 0; 0 1]);
model.component('componentPrism').geom('geom8').create('ext1', 'Extrude');
model.component('componentPrism').geom('geom8').feature('ext1').selection('input').set({'wp1'});
model.component('componentPrism').geom('geom8').run;
model.component('componentPrism').geom('geom8').run('fin');
model.component('componentGeneral2D').geom('geom9').label('geometryGeneral2D');
model.component('componentGeneral2D').geom('geom9').create('r1', 'Rectangle');
model.component('componentGeneral2D').geom('geom9').feature('r1').set('pos', [-0.65 -0.10000005662441]);
model.component('componentGeneral2D').geom('geom9').feature('r1').set('size', [1.35 0.75000005662441]);
model.component('componentGeneral2D').geom('geom9').create('c1', 'Circle');
model.component('componentGeneral2D').geom('geom9').feature('c1').set('pos', [-0.65 0.25]);
model.component('componentGeneral2D').geom('geom9').feature('c1').set('r', 0.4);
model.component('componentGeneral2D').geom('geom9').create('sca1', 'Scale');
model.component('componentGeneral2D').geom('geom9').feature('sca1').set('type', 'anisotropic');
model.component('componentGeneral2D').geom('geom9').feature('sca1').set('factor', [1 1.0625]);
model.component('componentGeneral2D').geom('geom9').feature('sca1').set('pos', [-0.65 0.65]);
model.component('componentGeneral2D').geom('geom9').feature('sca1').selection('input').set({'c1'});
model.component('componentGeneral2D').geom('geom9').create('mov1', 'Move');
model.component('componentGeneral2D').geom('geom9').feature('mov1').setIndex('disply', '-0.17', 0);
model.component('componentGeneral2D').geom('geom9').feature('mov1').selection('input').set({'sca1'});
model.component('componentGeneral2D').geom('geom9').create('b1', 'BezierPolygon');
model.component('componentGeneral2D').geom('geom9').feature('b1').set('p', [-1.05 -1.06 -0.65; 0.055 0.66 0.65]);
model.component('componentGeneral2D').geom('geom9').feature('b1').set('degree', [2]);
model.component('componentGeneral2D').geom('geom9').feature('b1').set('w', [1 0.7071067811865475 1]);
model.component('componentGeneral2D').geom('geom9').create('b2', 'BezierPolygon');
model.component('componentGeneral2D').geom('geom9').feature('b2').set('p', [-0.65 -0.65 -0.79 -0.68 -0.65; 0.65 0.47 0.45 0.62 0.65]);
model.component('componentGeneral2D').geom('geom9').feature('b2').set('degree', [1 1 1 1]);
model.component('componentGeneral2D').geom('geom9').feature('b2').set('w', [1 1 1 1 1 1 1 1]);
model.component('componentGeneral2D').geom('geom9').create('b3', 'BezierPolygon');
model.component('componentGeneral2D').geom('geom9').feature('b3').set('p', [0.1 0.7 0.7 0.7 1.15 1.65 1.65 1.8 1.7 1.25 0.6 0.2 -0.55; 0.65 0.65 0.95 1.15 1.15 1.15 0.95 0.35 -0.25 -0.5 -0.3 -0.2 -0.35]);
model.component('componentGeneral2D').geom('geom9').feature('b3').set('degree', [2 2 2 2 2 2]);
model.component('componentGeneral2D').geom('geom9').feature('b3').set('w', [1 0.7071067811865475 1 1 0.7071067811865475 1 1 0.7071067811865475 1 1 0.7071067811865475 1 1 0.7071067811865475 1 1 0.7071067811865475 1]);
model.component('componentGeneral2D').geom('geom9').create('fil1', 'Fillet');
model.component('componentGeneral2D').geom('geom9').feature('fil1').set('radius', 0.19);
model.component('componentGeneral2D').geom('geom9').feature('fil1').selection('point').set('b3(1)', 7);
model.component('componentGeneral2D').geom('geom9').create('uni1', 'Union');
model.component('componentGeneral2D').geom('geom9').feature('uni1').set('intbnd', false);
model.component('componentGeneral2D').geom('geom9').feature('uni1').selection('input').set({'b1' 'b2' 'fil1' 'mov1' 'r1'});
model.component('componentGeneral2D').geom('geom9').create('rot1', 'Rotate');
model.component('componentGeneral2D').geom('geom9').feature('rot1').setIndex('rot', '180', 0);
model.component('componentGeneral2D').geom('geom9').feature('rot1').set('pos', '0 0');
model.component('componentGeneral2D').geom('geom9').feature('rot1').selection('input').set({'uni1'});
model.component('componentGeneral2D').geom('geom9').feature('fin').set('repairtoltype', 'relative');
model.component('componentGeneral2D').geom('geom9').run;
model.component('componentGeneral2D').geom('geom9').run('fin');
model.component('componentGeneral3D').geom('geom10').label('geometryGeneral3D');
model.component('componentGeneral3D').geom('geom10').geomRep('comsol');
model.component('componentGeneral3D').geom('geom10').create('blk1', 'Block');
model.component('componentGeneral3D').geom('geom10').feature('blk1').set('pos', {'0' '0' '0.5[mm]/2+0.3[mm]'});
model.component('componentGeneral3D').geom('geom10').feature('blk1').set('base', 'center');
model.component('componentGeneral3D').geom('geom10').feature('blk1').set('size', {'2[mm]' '2.5[mm]' '0.5[mm]'});
model.component('componentGeneral3D').geom('geom10').create('blk2', 'Block');
model.component('componentGeneral3D').geom('geom10').feature('blk2').set('pos', {'0' '0' '-1.23[mm]/2'});
model.component('componentGeneral3D').geom('geom10').feature('blk2').set('base', 'center');
model.component('componentGeneral3D').geom('geom10').feature('blk2').set('size', {'4[mm]' '4[mm]' '1.23[mm]'});
model.component('componentGeneral3D').geom('geom10').feature('blk2').set('layername', {'Layer 1'});
model.component('componentGeneral3D').geom('geom10').feature('blk2').setIndex('layer', '0.07[mm]', 0);
model.component('componentGeneral3D').geom('geom10').feature('blk2').set('layerbottom', false);
model.component('componentGeneral3D').geom('geom10').feature('blk2').set('layertop', true);
model.component('componentGeneral3D').geom('geom10').create('sph1', 'Sphere');
model.component('componentGeneral3D').geom('geom10').feature('sph1').set('pos', {'2[mm]/2-0.25[mm]' '2.5[mm]/2-0.25[mm]' '0.15[mm]'});
model.component('componentGeneral3D').geom('geom10').feature('sph1').set('r', '0.4[mm]/2');
model.component('componentGeneral3D').geom('geom10').create('pard1', 'PartitionDomains');
model.component('componentGeneral3D').geom('geom10').feature('pard1').set('partitionwith', 'faces');
model.component('componentGeneral3D').geom('geom10').feature('pard1').selection('domain').set('sph1(1)', 1);
model.component('componentGeneral3D').geom('geom10').feature('pard1').selection('face').set('blk2(1)', 7);
model.component('componentGeneral3D').geom('geom10').feature('pard1').selection('face').set('blk1(1)', 1);
model.component('componentGeneral3D').geom('geom10').create('del1', 'Delete');
model.component('componentGeneral3D').geom('geom10').feature('del1').selection('input').init(3);
model.component('componentGeneral3D').geom('geom10').feature('del1').selection('input').set('pard1(1)', [2 3]);
model.component('componentGeneral3D').geom('geom10').create('arr1', 'Array');
model.component('componentGeneral3D').geom('geom10').feature('arr1').set('fullsize', [4 5 1]);
model.component('componentGeneral3D').geom('geom10').feature('arr1').set('displ', {'-(2[mm]-2*0.25[mm])/(4-1)' '-(2.5[mm]-2*0.25[mm])/(5-1)' '0'});
model.component('componentGeneral3D').geom('geom10').feature('arr1').selection('input').set({'del1'});
model.component('componentGeneral3D').geom('geom10').feature('fin').set('repairtoltype', 'relative');
model.component('componentGeneral3D').geom('geom10').run;
model.component('componentGeneral3D').geom('geom10').run('fin');

model.frame('material7').tag('material71');
model.frame('material2').tag('material7');
model.frame('material6').tag('material61');
model.frame('material3').tag('material6');
model.frame('material5').tag('material51');
model.frame('material4').tag('material5');
model.frame('material8').tag('material81');
model.frame('material51').tag('material8');
model.frame('material61').tag('material2');
model.frame('material71').tag('material3');
model.frame('material81').tag('material4');
model.frame('mesh7').tag('mesh71');
model.frame('mesh2').tag('mesh7');
model.frame('geometry7').tag('geometry71');
model.frame('geometry2').tag('geometry7');
model.frame('spatial7').tag('spatial71');
model.frame('spatial2').tag('spatial7');
model.frame('mesh6').tag('mesh61');
model.frame('mesh3').tag('mesh6');
model.frame('geometry6').tag('geometry61');
model.frame('geometry3').tag('geometry6');
model.frame('spatial6').tag('spatial61');
model.frame('spatial3').tag('spatial6');
model.frame('mesh5').tag('mesh51');
model.frame('mesh4').tag('mesh5');
model.frame('geometry5').tag('geometry51');
model.frame('geometry4').tag('geometry5');
model.frame('spatial5').tag('spatial51');
model.frame('spatial4').tag('spatial5');
model.frame('mesh8').tag('mesh81');
model.frame('mesh51').tag('mesh8');
model.frame('geometry8').tag('geometry81');
model.frame('geometry51').tag('geometry8');
model.frame('spatial8').tag('spatial81');
model.frame('spatial51').tag('spatial8');
model.frame('mesh61').tag('mesh2');
model.frame('geometry61').tag('geometry2');
model.frame('spatial61').tag('spatial2');
model.frame('mesh71').tag('mesh3');
model.frame('geometry71').tag('geometry3');
model.frame('spatial71').tag('spatial3');
model.frame('mesh81').tag('mesh4');
model.frame('geometry81').tag('geometry4');
model.frame('spatial81').tag('spatial4');

model.component('componentCylinder').view('view7').tag('view71');
model.component('componentTetrahedron').view('view2').tag('view7');
model.component('componentCone').view('view6').tag('view61');
model.component('componentHexahedron').view('view3').tag('view6');
model.component('componentPrism').view('view5').tag('view51');
model.component('componentPyramid').view('view4').tag('view5');
model.component('componentSphere').view('view8').tag('view81');
model.component('componentPrism').view('view51').tag('view8');
model.component('componentCone').view('view61').tag('view2');
model.component('componentCylinder').view('view71').tag('view3');
model.component('componentSphere').view('view81').tag('view4');
model.component('componentGeneral3D').view('view10').tag('view101');
model.component('componentGeneral2D').view('view9').tag('view10');
model.component('componentPrism').view('view11').tag('view111');
model.component('componentGeneral3D').view('view101').tag('view11');
model.component('componentPrism').view('view111').tag('view9');

model.component('componentCylinder').coordSystem('sys7').tag('sys71');
model.component('componentTetrahedron').coordSystem('sys2').tag('sys7');
model.component('componentCone').coordSystem('sys6').tag('sys61');
model.component('componentHexahedron').coordSystem('sys3').tag('sys6');
model.component('componentPrism').coordSystem('sys5').tag('sys51');
model.component('componentPyramid').coordSystem('sys4').tag('sys5');
model.component('componentSphere').coordSystem('sys8').tag('sys81');
model.component('componentPrism').coordSystem('sys51').tag('sys8');
model.component('componentCone').coordSystem('sys61').tag('sys2');
model.component('componentCylinder').coordSystem('sys71').tag('sys3');
model.component('componentSphere').coordSystem('sys81').tag('sys4');

model.component('componentGeneral3D').common.create('amth_ht2', 'AmbientProperties');

model.component('componentCube').mesh('mesh1').create('swe1', 'Sweep');
model.component('componentCube').mesh('mesh14').create('map1', 'Map');
model.component('componentCube').mesh('mesh14').feature('map1').selection.geom('geom1');
model.component('componentCube').mesh('mesh11').create('map1', 'Map');
model.component('componentCube').mesh('mesh11').feature('map1').selection.geom('geom1');
model.component('componentCube').mesh('mesh12').create('map1', 'Map');
model.component('componentCube').mesh('mesh12').feature('map1').selection.geom('geom1');
model.component('componentCube').mesh('mesh13').create('ftet1', 'FreeTet');
model.component('componentCube').mesh('mesh13').feature('ftet1').selection.geom('geom1');

model.component('componentCube').view('view1').set('ssao', true);
model.component('componentCube').view('view1').set('shadowmapping', true);
model.component('componentCone').view('view2').label('View 2');
model.component('componentCylinder').view('view3').label('View 3');
model.component('componentSphere').view('view4').label('View 4');
model.component('componentPyramid').view('view5').label('View 5');
model.component('componentHexahedron').view('view6').label('View 6');
model.component('componentTetrahedron').view('view7').label('View 7');
model.component('componentPrism').view('view8').label('View 8');
model.component('componentPrism').view('view9').label('View 9');
model.component('componentPrism').view('view9').axis.set('xmin', -0.11005499958992004);
model.component('componentPrism').view('view9').axis.set('xmax', 1.1100549697875977);
model.component('componentPrism').view('view9').axis.set('ymin', -0.050000011920928955);
model.component('componentPrism').view('view9').axis.set('ymax', 1.0499999523162842);
model.component('componentGeneral2D').view('view10').label('View 1');
model.component('componentGeneral2D').view('view10').axis.set('xmin', -1.8689301013946533);
model.component('componentGeneral2D').view('view10').axis.set('xmax', 1.1889965534210205);
model.component('componentGeneral2D').view('view10').axis.set('ymin', -1.7683712244033813);
model.component('componentGeneral2D').view('view10').axis.set('ymax', 0.9885274171829224);
model.component('componentGeneral3D').view('view11').label('View 3');

model.component('componentCone').coordSystem('sys2').label('Boundary System 2');
model.component('componentCone').coordSystem('sys2').set('name', 'sys2');
model.component('componentCylinder').coordSystem('sys3').label('Boundary System 3');
model.component('componentCylinder').coordSystem('sys3').set('name', 'sys3');
model.component('componentSphere').coordSystem('sys4').label('Boundary System 4');
model.component('componentSphere').coordSystem('sys4').set('name', 'sys4');
model.component('componentPyramid').coordSystem('sys5').label('Boundary System 5');
model.component('componentPyramid').coordSystem('sys5').set('name', 'sys5');
model.component('componentHexahedron').coordSystem('sys6').label('Boundary System 6');
model.component('componentHexahedron').coordSystem('sys6').set('name', 'sys6');
model.component('componentTetrahedron').coordSystem('sys7').label('Boundary System 7');
model.component('componentTetrahedron').coordSystem('sys7').set('name', 'sys7');
model.component('componentPrism').coordSystem('sys8').label('Boundary System 8');
model.component('componentPrism').coordSystem('sys8').set('name', 'sys8');
model.component('componentGeneral2D').coordSystem('sys9').label('Boundary System 1');
model.component('componentGeneral3D').coordSystem('sys10').label('Boundary System 3');

model.component('componentGeneral3D').common('amth_ht2').label('Ambient Thermal Properties (ht2)');
model.component('componentGeneral3D').common('amth_ht2').set('Ish_amb', '0[W/m^2]');

model.component('componentCube').mesh('mesh1').label('mesh9elemPerFaceStructuredQuadrilateral');
model.component('componentCube').mesh('mesh1').feature('size').set('hauto', 9);
model.component('componentCube').mesh('mesh1').feature('size').set('custom', 'on');
model.component('componentCube').mesh('mesh1').feature('size').set('hmax', 0.5);
model.component('componentCube').mesh('mesh1').feature('size').set('hmin', 0.5);
model.component('componentCube').mesh('mesh1').feature('swe1').selection('sourceface').set([1]);
model.component('componentCube').mesh('mesh1').feature('swe1').selection('targetface').set([6]);
model.component('componentCube').mesh('mesh1').run;
model.component('componentCube').mesh('mesh14').label('meshEtremelyCoarseStructuredQuadrilateral');
model.component('componentCube').mesh('mesh14').feature('size').set('hauto', 9);
model.component('componentCube').mesh('mesh14').run;
model.component('componentGeneral2D').mesh('mesh9').label('Mesh 1');
model.component('componentGeneral3D').mesh('mesh10').label('Mesh 3');
model.component('componentCube').mesh('mesh11').label('meshNormalStructuredQuadrilateral');
model.component('componentCube').mesh('mesh11').run;
model.component('componentCube').mesh('mesh12').label('meshEtremelyFineStructuredQuadrilateral');
model.component('componentCube').mesh('mesh12').feature('size').set('hauto', 1);
model.component('componentCube').mesh('mesh12').run;
model.component('componentCube').mesh('mesh13').label('meshNormalFreeTetrahedral');
model.component('componentCube').mesh('mesh13').run;

out = model;
