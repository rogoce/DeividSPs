-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sac120;

create procedure "informix".sp_sac120()
returning integer,
          char(50);

define _cuentas	char(25);
define _ano     smallint;
define _ene		dec(16,2);
define _feb		dec(16,2);
define _mar		dec(16,2);
define _abr		dec(16,2);
define _may		dec(16,2);
define _jun		dec(16,2);
define _jul		dec(16,2);
define _ago		dec(16,2);
define _sep		dec(16,2);
define _oct		dec(16,2);
define _nov		dec(16,2);
define _dic		dec(16,2);

-- Presupuesto del 2010

let _ano     = 2010;

-- Fianzas

-- Primas Suscritas
   
let _cuentas = "411030104";

delete from sac:cglprera
 where ano    = _ano
   and cuenta = _cuentas;

let _ene = 1862972.32; 	 
let _feb = 1864948.58; 	 
let _mar = 1929765.81;
let _abr = 1829861.48; 	 
let _may = 1981979.49; 	 
let _jun = 1873124.29; 	 
let _jul = 1909539.78; 	 
let _ago = 1918539.94; 	 
let _sep = 1954157.98; 	 
let _oct = 1866205.98; 	 
let _nov = 1857919.36; 	 
let _dic = 1857482.56; 

insert into sac:cglprera values (_ano, _cuentas, 1,  _ene);
insert into sac:cglprera values (_ano, _cuentas, 2,  _feb);
insert into sac:cglprera values (_ano, _cuentas, 3,  _mar);
insert into sac:cglprera values (_ano, _cuentas, 4,  _abr);
insert into sac:cglprera values (_ano, _cuentas, 5,  _may);
insert into sac:cglprera values (_ano, _cuentas, 6,  _jun);
insert into sac:cglprera values (_ano, _cuentas, 7,  _jul);
insert into sac:cglprera values (_ano, _cuentas, 8,  _ago);
insert into sac:cglprera values (_ano, _cuentas, 9,  _sep);
insert into sac:cglprera values (_ano, _cuentas, 10, _oct);
insert into sac:cglprera values (_ano, _cuentas, 11, _nov);
insert into sac:cglprera values (_ano, _cuentas, 12, _dic);

-- Comisiones Ganadas en Reaseguro Cedido
   
let _cuentas = "411030104";

delete from sac:cglprera
 where ano    = _ano
   and cuenta = _cuentas;

let _ene = 1862972.32; 	 
let _feb = 1864948.58; 	 
let _mar = 1929765.81;
let _abr = 1829861.48; 	 
let _may = 1981979.49; 	 
let _jun = 1873124.29; 	 
let _jul = 1909539.78; 	 
let _ago = 1918539.94; 	 
let _sep = 1954157.98; 	 
let _oct = 1866205.98; 	 
let _nov = 1857919.36; 	 
let _dic = 1857482.56; 

insert into sac:cglprera values (_ano, _cuentas, 1,  _ene);
insert into sac:cglprera values (_ano, _cuentas, 2,  _feb);
insert into sac:cglprera values (_ano, _cuentas, 3,  _mar);
insert into sac:cglprera values (_ano, _cuentas, 4,  _abr);
insert into sac:cglprera values (_ano, _cuentas, 5,  _may);
insert into sac:cglprera values (_ano, _cuentas, 6,  _jun);
insert into sac:cglprera values (_ano, _cuentas, 7,  _jul);
insert into sac:cglprera values (_ano, _cuentas, 8,  _ago);
insert into sac:cglprera values (_ano, _cuentas, 9,  _sep);
insert into sac:cglprera values (_ano, _cuentas, 10, _oct);
insert into sac:cglprera values (_ano, _cuentas, 11, _nov);
insert into sac:cglprera values (_ano, _cuentas, 12, _dic);

 124,719.15 	 128,923.72 	 141,655.83 	 119,147.41 	 144,196.08 	 128,659.20 	 132,132.34 	 145,658.28 	 128,309.85 	 127,346.48 	 125,806.81 	 125,806.81 


-- Presupuesto del 2009
{
foreach
 select cuentas,
		ene,
		feb,
		mar,
		abr,
		may,
		jun,
		jul,
		ago,
		sep,
		oct,
		nov,
		dic
   into _cuentas,
		_ene,
		_feb,
		_mar,
		_abr,
		_may,
		_jun,
		_jul,
		_ago,
		_sep,
		_oct,
		_nov,
		_dic
   from deivid_tmp:tmp_cglprera

	insert into sac:cglprera values (2009, _cuentas, 1, _ene);
	insert into sac:cglprera values (2009, _cuentas, 2, _feb);
	insert into sac:cglprera values (2009, _cuentas, 3, _mar);
	insert into sac:cglprera values (2009, _cuentas, 4, _abr);
	insert into sac:cglprera values (2009, _cuentas, 5, _may);
	insert into sac:cglprera values (2009, _cuentas, 6, _jun);
	insert into sac:cglprera values (2009, _cuentas, 7, _jul);
	insert into sac:cglprera values (2009, _cuentas, 8, _ago);
	insert into sac:cglprera values (2009, _cuentas, 9, _sep);
	insert into sac:cglprera values (2009, _cuentas, 10, _oct);
	insert into sac:cglprera values (2009, _cuentas, 11, _nov);
	insert into sac:cglprera values (2009, _cuentas, 12, _dic);

end foreach
}

return 0, "Actualizacion Exitosa";

end procedure
