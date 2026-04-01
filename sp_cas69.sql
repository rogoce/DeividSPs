-- Retorna el Resumen Historico de gestiones por dia en detalle
-- Para un gestor y dia dado
-- 
-- Creado    : 11/09/2003 - Autor:Armando Moreno
-- Modificado: 11/09/2003 - Autor:Armando Moreno
--

drop procedure sp_cas69;

create procedure sp_cas69(a_fecha_desde date, a_fecha_hasta date)
returning char(50),
		  char(3),
          integer,
          integer,
          integer,
          integer,
          integer,
          integer,
          integer,
          integer,
          integer;

define _cod_ausencia    char(3);
define _cod_cobrador    char(3);
define _cod_gestion     char(3);
define _nombre_cobrador	char(50);
define _fecha_ini		datetime year to fraction(5);
define _fecha_fin		datetime year to fraction(5);
define _hora_dif		char(30);
define _hora_min		char(8);
define _min_num			integer;
define _seg_num			integer;
define _hora_num		integer;
define _min_num2 		integer;
define _seg_num2		integer;
define _hora_num2		integer;
define _min_num3 		integer;
define _seg_num3		integer;
define _hora_num3		integer;
--set debug file to "sp_cas68.trc";
--trace on;

foreach
 select h.cod_cobrador,
        h.cod_gestion,
		h.fecha_ini,
		h.fecha_fin,
		h.cod_ausencia
   into _cod_cobrador,
        _cod_gestion,
		_fecha_ini,
		_fecha_fin,
		_cod_ausencia
   from cobcahis h, cobcobra c
  where date(h.fecha_ini) >= a_fecha_desde
    and date(h.fecha_ini) <= a_fecha_hasta
	and h.cod_cobrador = c.cod_cobrador
	and c.tipo_cobrador not in (7, 8)

	let _hora_dif = _fecha_fin - _fecha_ini;
	let _hora_dif = trim(_hora_dif);
	let _hora_min = _hora_dif[3,10];
	let _seg_num2  = 0;
	let _min_num2  = 0;
	let _hora_num2 = 0;
	let _seg_num   = 0;
	let _min_num   = 0;
	let _hora_num  = 0;
	let _seg_num3  = 0;
	let _min_num3  = 0;
	let _hora_num3 = 0;

 if _cod_gestion is not null then	--tiempos con gestion
	let _hora_num = _hora_dif[3,4];
	let _min_num  = _hora_dif[6,7];
	let _seg_num  = _hora_dif[9,10];
 else
	if _cod_ausencia is null then	--tiempos oseo sin ausencia
		let _hora_num2 = _hora_dif[3,4];
		let _min_num2  = _hora_dif[6,7];
		let _seg_num2  = _hora_dif[9,10];
	else
		let _hora_num3 = _hora_dif[3,4];
		let _min_num3  = _hora_dif[6,7];
		let _seg_num3  = _hora_dif[9,10];
	end if
 end if

 select nombre
   into _nombre_cobrador
   from cobcobra
  where cod_cobrador = _cod_cobrador;

	return _nombre_cobrador,
		   _cod_cobrador,
		   _min_num,
		   _seg_num,
		   _hora_num2,
		   _min_num2,
		   _seg_num2,
		   _hora_num3,
		   _min_num3,
		   _seg_num3,
           _hora_num
		   with resume;

end foreach

end procedure


				  