-- Procedimiento que carga los datos para presupuesto del 2010 por ramo
 
-- 20/11/2009 - Autor: Armando Moreno M.

drop procedure sp_preram6;

create procedure "informix".sp_preram6(a_tipo_mov char(2), _tipo_mov2 char(2), a_bono char(1))
returning integer,
		  char(100);

define _cod_ramo		char(3);
define _tipo_mov		char(2);

define _nueva_renov		char(1);
define _vigencia_inic	date;
define _vigencia_final	date;

define _no_poliza		char(10);
define _no_endoso		char(5);
define _periodo			char(7);
define _prima_suscrita	dec(16,2);
define _p_sus_cont      dec(16,2);
define _p_sus           dec(16,2);
define _prima_retenida  dec(16,2);
define _cod_endomov		char(3);
define _cod_contrato	char(5);
define _fronting		smallint;
define _tipo_contrato   smallint;
define _error_desc		char(100);
define _p_ced_tot		dec(16,2);
define _comision		dec(16,2);
define _mes_char        CHAR(2);
define _ano_char		CHAR(4);
define _fecha_genera    date;
define _total_2009		dec(16,2);
define _total_2008		dec(16,2);
define _porc_ene		dec(16,5);
define _porc_feb		dec(16,5);
define _porc_mar		dec(16,5);
define _porc_abr		dec(16,5);
define _porc_may		dec(16,5);
define _porc_jun		dec(16,5);
define _porc_jul		dec(16,5);
define _porc_ago		dec(16,5);
define _porc_sep		dec(16,5);
define _porc_oct		dec(16,5);
define _porc_nov		dec(16,5);
define _porc_dic		dec(16,5);
define _porc_09         dec(16,5);
define _ene2			dec(16,2);
define _feb2			dec(16,2);
define _mar2			dec(16,2);
define _abr2			dec(16,2);
define _may2			dec(16,2);
define _jun2			dec(16,2);
define _jul2			dec(16,2);
define _ago2			dec(16,2);
define _sep2			dec(16,2);
define _oct2			dec(16,2);
define _nov2			dec(16,2);
define _dic2			dec(16,2);
define _ene			    dec(16,2);
define _feb				dec(16,2);
define _mar				dec(16,2);
define _abr				dec(16,2);
define _may				dec(16,2);
define _jun				dec(16,2);
define _jul				dec(16,2);
define _ago				dec(16,2);
define _sep				dec(16,2);
define _oct				dec(16,2);
define _nov				dec(16,2);
define _dic				dec(16,2);

let _tipo_mov = a_tipo_mov;

if a_bono = "1" then --cobranza

foreach

		select cod_ramo,
		       periodo,
		       sum(comision)
		  into _cod_ramo,
		       _periodo,
			   _comision
	      from chqboni
		 where no_requis is not null
		   and periodo >= "2008-11"
		   and periodo <= "2009-10"
		 group by cod_ramo,periodo
		 order by cod_ramo,periodo

	-- Movimientos Mensuales

	if _periodo[6,7] = "01" then

		update preram2010
		   set ene          = ene + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "02" then

		update preram2010
		   set feb          = feb + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "03" then

		update preram2010
		   set mar          = mar + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "04" then

		update preram2010
		   set abr          = abr + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "05" then

		update preram2010
		   set may          = may + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "06" then

		update preram2010
		   set jun          = jun + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "07" then

		update preram2010
		   set jul          = jul + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "08" then

		update preram2010
		   set ago          = ago + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "09" then

		update preram2010
		   set sep          = sep + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "10" then

		update preram2010
		   set oct          = oct + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "11" then

		update preram2010
		   set nov          = nov + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "12" then

		update preram2010
		   set dic          = dic + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	end if


end foreach

elif a_bono = "2" then --fidelidad

foreach

		select cod_ramo,
		       periodo,
		       sum(comision)
		  into _cod_ramo,
		       _periodo,
			   _comision
	      from chqfidel
		 where no_requis is not null
		   and periodo >= "2008-11"
		   and periodo <= "2009-10"
		 group by cod_ramo,periodo
		 order by cod_ramo,periodo

	-- Movimientos Mensuales

	if _periodo[6,7] = "01" then

		update preram2010
		   set ene          = ene + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "02" then

		update preram2010
		   set feb          = feb + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "03" then

		update preram2010
		   set mar          = mar + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "04" then

		update preram2010
		   set abr          = abr + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "05" then

		update preram2010
		   set may          = may + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "06" then

		update preram2010
		   set jun          = jun + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "07" then

		update preram2010
		   set jul          = jul + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "08" then

		update preram2010
		   set ago          = ago + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "09" then

		update preram2010
		   set sep          = sep + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "10" then

		update preram2010
		   set oct          = oct + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "11" then

		update preram2010
		   set nov          = nov + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "12" then

		update preram2010
		   set dic          = dic + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	end if


end foreach

elif a_bono = "3" then --Rentabilidad

foreach

		select cod_ramo,
		       periodo,
		       sum(comision)
		  into _cod_ramo,
		       _periodo,
			   _comision
	      from chqrenta3
		 where no_requis is not null
		   and periodo >= "2008-11"
		   and periodo <= "2009-10"
		 group by cod_ramo,periodo
		 order by cod_ramo,periodo

	-- Movimientos Mensuales

	if _periodo[6,7] = "01" then

		update preram2010
		   set ene          = ene + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "02" then

		update preram2010
		   set feb          = feb + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "03" then

		update preram2010
		   set mar          = mar + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "04" then

		update preram2010
		   set abr          = abr + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "05" then

		update preram2010
		   set may          = may + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "06" then

		update preram2010
		   set jun          = jun + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "07" then

		update preram2010
		   set jul          = jul + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "08" then

		update preram2010
		   set ago          = ago + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "09" then

		update preram2010
		   set sep          = sep + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "10" then

		update preram2010
		   set oct          = oct + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "11" then

		update preram2010
		   set nov          = nov + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "12" then

		update preram2010
		   set dic          = dic + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	end if


end foreach

elif a_bono = "4" then --Reclutamiento

foreach

		select cod_ramo,
		       periodo,
		       sum(comision)
		  into _cod_ramo,
		       _periodo,
			   _comision
	      from chqff
		 where no_requis is not null
		   and periodo >= "2008-11"
		   and periodo <= "2009-10"
		 group by cod_ramo,periodo
		 order by cod_ramo,periodo

	-- Movimientos Mensuales

	if _periodo[6,7] = "01" then

		update preram2010
		   set ene          = ene + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "02" then

		update preram2010
		   set feb          = feb + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "03" then

		update preram2010
		   set mar          = mar + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "04" then

		update preram2010
		   set abr          = abr + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "05" then

		update preram2010
		   set may          = may + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "06" then

		update preram2010
		   set jun          = jun + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "07" then

		update preram2010
		   set jul          = jul + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "08" then

		update preram2010
		   set ago          = ago + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "09" then

	  	update preram2010
		   set sep          = sep + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "10" then

		update preram2010
		   set oct          = oct + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "11" then

		update preram2010
		   set nov          = nov + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "12" then

		update preram2010
		   set dic          = dic + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	end if

end foreach

end if

-- Totales Horizontales

foreach
 select cod_ramo,
		tipo_mov,
		(ene + feb + mar + abr + may + jun + jul + ago + sep + oct + nov + dic)
   into _cod_ramo,
		_tipo_mov,
		_total_2009
   from preram2010
  where tipo_mov = _tipo_mov
   order by 1,2

 update preram2010
    set total_2009   = _total_2009
  where cod_ramo     = _cod_ramo
    and tipo_mov     = _tipo_mov;

end foreach

-- Calculo del % cobranza

foreach
	 select cod_ramo,
			tipo_mov,
			ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total_2009
	   into _cod_ramo,
			_tipo_mov,
			_ene2,_feb2,_mar2,_abr2,_may2,_jun2,_jul2,_ago2,_sep2,_oct2,_nov2,_dic2,_total_2009
	   from preram2010
	  where tipo_mov = _tipo_mov
	  order by 1

	select ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total_2009
	  into _ene,_feb,_mar,_abr,_may,_jun,_jul,_ago,_sep,_oct,_nov,_dic,_total_2008
	  from preram2010
	 where cod_ramo   = _cod_ramo
	   and tipo_mov   = "8";

	let _porc_ene =	0;
	let _porc_feb =	0;
	let _porc_mar =	0;
	let _porc_abr =	0;
	let _porc_may =	0;
	let _porc_jun =	0;
	let _porc_jul =	0;
	let _porc_ago =	0;
	let _porc_sep =	0;
	let _porc_oct =	0;
	let _porc_nov =	0;
	let _porc_dic =	0;
	let _porc_09  = 0;

	if _total_2008 <> 0 then
		let _porc_09 =  (_total_2009 / _total_2008) * 100;
	end if

	if _ene <> 0 then
		let _porc_ene =  (_ene2 / _ene) * 100;
	end if
	if _feb <> 0 then
		let _porc_feb =  (_feb2 / _feb) * 100;
	end if
	if _mar <> 0 then
		let _porc_mar =  (_mar2 / _mar) * 100;
	end if
	if _abr <> 0 then
		let _porc_abr =  (_abr2 / _abr) * 100;
	end if
	if _may <> 0 then
		let _porc_may =  (_may2 / _may) * 100;
	end if
	if _jun <> 0 then
		let _porc_jun =  (_jun2 / _jun) * 100;
	end if
	if _jul <> 0 then
		let _porc_jul =  (_jul2 / _jul) * 100;
	end if
	if _ago <> 0 then
		let _porc_ago =  (_ago2 / _ago) * 100;
	end if
	if _sep <> 0 then
		let _porc_sep =  (_sep2 / _sep) * 100;
	end if
	if _oct <> 0 then
		let _porc_oct =  (_oct2 / _oct) * 100;
	end if
	if _nov <> 0 then
		let _porc_nov =  (_nov2 / _nov) * 100;
	end if
	if _dic <> 0 then
		let _porc_dic =  (_dic2 / _dic) * 100;
	end if

	update preram2010
	   set ene = _porc_ene,
		   feb = _porc_feb,
		   mar = _porc_mar,
		   abr = _porc_abr,
		   may = _porc_may,
		   jun = _porc_jun,
		   jul = _porc_jul,
		   ago = _porc_ago,
		   sep = _porc_sep,
		   oct = _porc_oct,
		   nov = _porc_nov,
		   dic = _porc_dic,
	  total_2009 = _porc_09
 	 where cod_ramo = _cod_ramo
  	   and tipo_mov = _tipo_mov2;

end foreach

return 0, "Actualizacion Exitosa";

end procedure