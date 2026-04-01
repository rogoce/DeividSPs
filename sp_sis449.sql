-- Procedimiento que Actualiza masivamente los número de recibos en caso de salto de secuencia
-- Creado    : 20/01/2017 - Autor: Román Gordón

drop procedure sp_sis449;
create procedure sp_sis449(a_sexo char(1), a_tara char(2))
returning	dec(16,2)	as Lx,
			dec(16,2)	as Qx,
			dec(16,2)	as d,
			dec(16,2)	as dx,
			dec(16,2)	as Nx,
			dec(16,2)	as Sx,
			dec(16,2)	as Cx,
			dec(16,2)	as Mx,
			dec(16,2)	as Rx,
			dec(16,2)	as PC;

define _lx			dec(16,2);
define _edad		smallint;
define _cnt_x		smallint;
define _cnt_y		smallint;
define _error		integer;
define lx			list(dec(16,2) not null);
{define qx			array[120] of dec(16,2);
define d			array[120] of dec(16,2);
define Dx			array[120] of dec(16,2);
define Nx 			array[120] of dec(16,2);
define Sx			array[120] of dec(16,2);
define Cx			array[120] of dec(16,2);
define Mx			array[120] of dec(16,2);
define Rx			array[120] of dec(16,2);
define Pc			array[120] of dec(16,2);}

set isolation to dirty read;

begin

let _porc_intec = 3/100;

foreach
	select edad,
		   valor
	  into _edad,
		   _lx
	  from mortalidad
	 where sexo = a_sexo
	   and tara = a_tara

	let _cnt_x = 0;
	let lx(_cnt_x) = _lx;
	
	let _cnt_x = _cnt_x + 1;
end foreach
{
--qx
for _cnt_x = 0 to 120
	let _cnt_y = _cnt_x + 1;
	let qx[_cnt_x] = ((lx[_cnt_x] - lx[_cnt_y])/ lx[_cnt_x]) * 1000;
end for

--dx
for _cnt_x = 0 to 120
	let d[_cnt_x] = (lx[_cnt_x]* qx[_cnt_x]) / 1000;
end for

--Dx
for _cnt_x = 0 to 120
	let Dx[_cnt_x] = lx[_cnt_x] * pow((1/(1 + _porc_intec)),_cnt_x);
end for

--Nx
for _cnt_x = 120 to 0 step -1
	let _cnt_y =_cnt_x + 1;	
	let Nx[_cnt_x] = (lx[_cnt_x] * pow((1/(1 + _porc_intec)),_cnt_x)) + Nx[_cnt_y];
end for

--Sx
for _cnt_x = 120 to 0 step -1
	let _cnt_y =_cnt_x + 1;	
	let Sx[_cnt_x] =  Nx[_cnt_x] + Sx[_cnt_y];
end for

--Cx
for _cnt_x = 0 to 120
	let Cx[_cnt_x] = d[_cnt_x] * pow((1/(1 + _porc_intec)),(_cnt_x + 1));
end for

--Mx
for _cnt_x = 120 to 0 step -1
	let _cnt_y =_cnt_x + 1;	
	let Mx[_cnt_x] =  Cx[_cnt_x] + Mx[_cnt_y];
end for

--Rx
for _cnt_x = 120 to 0 step -1
	let _cnt_y =_cnt_x + 1;	
	let Rx[_cnt_x] =  Mx[_cnt_x] + Rx[_cnt_y];
end for

--Prima Comercial
for _cnt_x = 0 to 120
	let Pc[_cnt_x] = (Mx[_cnt_x]*1000)/ Nx[_cnt_x];
end for

for _cnt_x = 0 to 120
	return	lx[_cnt_x],
			qx[_cnt_x],
			d[_cnt_x],
			Dx[_cnt_x],
			Nx[_cnt_x],
			Sx[_cnt_x],
			Cx[_cnt_x],
			Mx[_cnt_x],
			Rx[_cnt_x],
			Pc[_cnt_x] with resume;
end for}
end
end procedure;