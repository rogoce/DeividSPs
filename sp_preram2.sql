-- Procedimiento que carga la tabla preram2010
 
-- Creado     :	17/11/2009 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_preram2;

create procedure "informix".sp_preram2()
returning integer,
		  char(100);

define _cod_ramo	 	char(3);
define _tipo_mov		char(2);

define _ene				dec(16,2);
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
define _total_2009		dec(16,2);
define _total_2008		dec(16,2);
define _nueva_porc		dec(16,2);

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
define _total_2			dec(16,2);

define _error			integer;
define _error_desc		char(100);

-- Esquema Incial

set isolation to dirty read;

return 0, "Eliminando tipo_mov = 1" with resume;
delete from preram2010 where tipo_mov = "1";

return 0, "Eliminando tipo_mov = 2" with resume;
delete from preram2010 where tipo_mov = "2";

return 0, "Eliminando tipo_mov = 3" with resume;
delete from preram2010 where tipo_mov = "3";

return 0, "Eliminando tipo_mov = 4" with resume;
delete from preram2010 where tipo_mov = "4";

return 0, "Eliminando tipo_mov = 5" with resume;
delete from preram2010 where tipo_mov = "5";

return 0, "Eliminando tipo_mov = 6" with resume;
delete from preram2010 where tipo_mov = "6";

return 0, "Eliminando tipo_mov = 7" with resume;
delete from preram2010 where tipo_mov = "7";

return 0, "Eliminando tipo_mov = 8" with resume;
delete from preram2010 where tipo_mov = "8";

return 0, "Eliminando tipo_mov = 30" with resume;
delete from preram2010 where tipo_mov = "30";

return 0, "Eliminando tipo_mov = 31" with resume;
delete from preram2010 where tipo_mov = "31";
     
return 0, "Eliminando tipo_mov = 32" with resume;
delete from preram2010 where tipo_mov = "32";

return 0, "Eliminando tipo_mov = 33" with resume;
delete from preram2010 where tipo_mov = "33";

return 0, "Eliminando tipo_mov = 34" with resume;
delete from preram2010 where tipo_mov = "34";

return 0, "Eliminando tipo_mov = 40" with resume;
delete from preram2010 where tipo_mov = "40";

return 0, "Eliminando tipo_mov = 41" with resume;
delete from preram2010 where tipo_mov = "41";

return 0, "Eliminando tipo_mov = 42" with resume;
delete from preram2010 where tipo_mov = "42";

return 0, "Eliminando tipo_mov = 43" with resume;
delete from preram2010 where tipo_mov = "43";

return 0, "Eliminando tipo_mov = 44" with resume;
delete from preram2010 where tipo_mov = "44";

return 0, "Eliminando tipo_mov = 45" with resume;
delete from preram2010 where tipo_mov = "45";

return 0, "Eliminando tipo_mov = 50" with resume;
delete from preram2010 where tipo_mov = "50";

return 0, "Eliminando tipo_mov = 51" with resume;
delete from preram2010 where tipo_mov = "51";

return 0, "Eliminando tipo_mov = 52" with resume;
delete from preram2010 where tipo_mov = "52";

return 0, "Eliminando tipo_mov = 53" with resume;
delete from preram2010 where tipo_mov = "53";

return 0, "Eliminando tipo_mov = 54" with resume;
delete from preram2010 where tipo_mov = "54";     

return 0, "Eliminando tipo_mov = 55" with resume;
delete from preram2010 where tipo_mov = "55";

return 0, "Eliminando tipo_mov = 56" with resume;
delete from preram2010 where tipo_mov = "56";

return 0, "Eliminando tipo_mov = 57" with resume;
delete from preram2010 where tipo_mov = "57";

return 0, "Eliminando tipo_mov = 58" with resume;
delete from preram2010 where tipo_mov = "58";

return 0, "Eliminando tipo_mov = 59" with resume;
delete from preram2010 where tipo_mov = "59";

return 0, "Eliminando tipo_mov = 60" with resume;
delete from preram2010 where tipo_mov = "60";

return 0, "Eliminando tipo_mov = 61" with resume;
delete from preram2010 where tipo_mov = "61";

return 0, "Eliminando tipo_mov = 62" with resume;
delete from preram2010 where tipo_mov = "62";

return 0, "Eliminando tipo_mov = 70" with resume;
delete from preram2010 where tipo_mov = "70";

return 0, "Eliminando tipo_mov = 71" with resume;
delete from preram2010 where tipo_mov = "71";

return 0, "Eliminando tipo_mov = 72" with resume;
delete from preram2010 where tipo_mov = "72";

return 0, "Eliminando tipo_mov = 73" with resume;
delete from preram2010 where tipo_mov = "73";

return 0, "Creando el Esquema Inicial" with resume;	

foreach

	select cod_ramo
	  into _cod_ramo
	  from prdramo			 
	 order by 1

  	insert into preram2010
	values (_cod_ramo, "1",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "2",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "3",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "4",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "5",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "6",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "7",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);	 

	insert into preram2010
	values (_cod_ramo, "8",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);	 

	insert into preram2010
	values (_cod_ramo, "30",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "31",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);  	 

	insert into preram2010
	values (_cod_ramo, "32",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "33",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);	 

	insert into preram2010
	values (_cod_ramo, "34",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);	 

   	insert into preram2010
	values (_cod_ramo, "40",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "41",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "42",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "43",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "44",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "45",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);  

   	insert into preram2010
	values (_cod_ramo, "50",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "51",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "52",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "53",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "54",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "55",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);	 

	insert into preram2010
	values (_cod_ramo, "56",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "57",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "58",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

  	insert into preram2010
	values (_cod_ramo, "59",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00); 

	insert into preram2010
 	values (_cod_ramo, "60",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00); 

	insert into preram2010
	values (_cod_ramo, "61",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "62",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);    

	insert into preram2010
	values (_cod_ramo, "70",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00); 

	insert into preram2010
	values (_cod_ramo, "71",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00); 

	insert into preram2010
	values (_cod_ramo, "72",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

	insert into preram2010
	values (_cod_ramo, "73",0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

end foreach

-- Calculo de la Parte A

return 0, "Calculo de la Parte A" with resume;


call sp_preram1() returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if 	

-- Totales Horizontales

--return 0, "Totales Horizontales" with resume;

foreach
 select cod_ramo,
		tipo_mov,
		(ene + feb + mar + abr + may + jun + jul + ago + sep + oct + nov + dic)
   into _cod_ramo,
		_tipo_mov,
		_total_2009
   from preram2010
   order by 1,2

	update preram2010
	   set total_2009   = _total_2009
	 where cod_ramo     = _cod_ramo
	   and tipo_mov     = _tipo_mov;

end foreach	 

-- Calculo del % de Cesion

return 0, "Calculo del % de Cesion" with resume;

foreach

 select cod_ramo,
		tipo_mov,
		ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total_2009
   into _cod_ramo,
		_tipo_mov,
		_ene2,_feb2,_mar2,_abr2,_may2,_jun2,_jul2,_ago2,_sep2,_oct2,_nov2,_dic2,_total_2009
   from preram2010
  where tipo_mov = "5"
  order by 1

	select ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total_2009
	  into _ene,_feb,_mar,_abr,_may,_jun,_jul,_ago,_sep,_oct,_nov,_dic,_total_2008
	  from preram2010
	 where cod_ramo   = _cod_ramo
	   and tipo_mov   = "1";

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
  	   and tipo_mov = '6';

end foreach	  


-- Calculo de la Parte D **Siniestros**

return 0, "Calculo de la Parte D" with resume;


call sp_preram3() returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if

-- Totales Horizontales

return 0, "Totales Horizontales" with resume;

foreach
 select cod_ramo,
		tipo_mov,
		(ene + feb + mar + abr + may + jun + jul + ago + sep + oct + nov + dic)
   into _cod_ramo,
		_tipo_mov,
		_total_2009
   from preram2010
  where tipo_mov in("40","42")
   order by 1,2

 update preram2010
    set total_2009   = _total_2009
  where cod_ramo     = _cod_ramo
    and tipo_mov     = _tipo_mov;

end foreach

-- Calculo del % de Inc. Bruto

return 0, "Calculo del % de Inc. Bruto" with resume;

foreach
	 select cod_ramo,
			tipo_mov,
			ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total_2009
	   into _cod_ramo,
			_tipo_mov,
			_ene2,_feb2,_mar2,_abr2,_may2,_jun2,_jul2,_ago2,_sep2,_oct2,_nov2,_dic2,_total_2009
	   from preram2010
	  where tipo_mov = "40"
	  order by 1

	select ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total_2009
	  into _ene,_feb,_mar,_abr,_may,_jun,_jul,_ago,_sep,_oct,_nov,_dic,_total_2008
	  from preram2010
	 where cod_ramo   = _cod_ramo
	   and tipo_mov   = "1";

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
  	   and tipo_mov = '41';

end foreach

-- Calculo del % de Inc. Neto

return 0, "Calculo del % de Inc. Neto" with resume;

foreach
	 select cod_ramo,
			tipo_mov,
			ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total_2009
	   into _cod_ramo,
			_tipo_mov,
			_ene2,_feb2,_mar2,_abr2,_may2,_jun2,_jul2,_ago2,_sep2,_oct2,_nov2,_dic2,_total_2009
	   from preram2010
	  where tipo_mov = "42"
	  order by 1

	select ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total_2009
	  into _ene,_feb,_mar,_abr,_may,_jun,_jul,_ago,_sep,_oct,_nov,_dic,_total_2008
	  from preram2010
	 where cod_ramo   = _cod_ramo
	   and tipo_mov   = "2";

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
  	   and tipo_mov = '43';

end foreach

-- Calculo de la Prima cobrada

return 0, "Calculo de la prima cobrada" with resume;


call sp_preram10() returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if	
	   

-- Calculo de la Parte E

return 0, "Calculo de la Parte E" with resume;


call sp_preram5() returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if 		 

-- Totales Horizontales

return 0, "Totales Horizontales" with resume;

foreach
 select cod_ramo,
		tipo_mov,
		(ene + feb + mar + abr + may + jun + jul + ago + sep + oct + nov + dic)
   into _cod_ramo,
		_tipo_mov,
		_total_2009
   from preram2010
  where tipo_mov in("50")
   order by 1,2

 update preram2010				  
    set total_2009   = _total_2009
  where cod_ramo     = _cod_ramo
    and tipo_mov     = _tipo_mov;

end foreach 

-- Calculo del % comision

return 0, "Calculo del % comision" with resume;

foreach
	 select cod_ramo,
			tipo_mov,
			ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total_2009
	   into _cod_ramo,
			_tipo_mov,
			_ene2,_feb2,_mar2,_abr2,_may2,_jun2,_jul2,_ago2,_sep2,_oct2,_nov2,_dic2,_total_2009
	   from preram2010
	  where tipo_mov = "50"
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
  	   and tipo_mov = '51';

end foreach

--Cobranza
call sp_preram6("52","53", "1") returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if	 

--Fidelidad
call sp_preram6("54","55", "2") returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if 		 

--Rentabilidad
call sp_preram6("56","57", "3") returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if 		 

--Reclutamiento
call sp_preram6("58","59", "4") returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if

-- Totales Horizontales

return 0, "Totales Horizontales" with resume;

foreach

	 select cod_ramo,
	 		sum(ene),sum(feb),sum(mar),sum(abr),sum(may),sum(jun),sum(jul),sum(ago),sum(sep),sum(oct),sum(nov),sum(dic)
	   into _cod_ramo,
			_ene2,_feb2,_mar2,_abr2,_may2,_jun2,_jul2,_ago2,_sep2,_oct2,_nov2,_dic2
	   from preram2010
	  where tipo_mov in("50","52","54","56","58")
	  group by 1
	  order by 1

	 update preram2010
	    set ene 	 = _ene2,
		    feb      = _feb2,
			mar		 = _mar2,
			abr		 = _abr2,
			may		 = _may2,
			jun		 = _jun2,
			jul		 = _jul2,
			ago		 = _ago2,
			sep		 = _sep2,
			oct		 = _oct2,
			nov		 = _nov2,
			dic		 = _dic2
	  where cod_ramo     = _cod_ramo
	    and tipo_mov     = "60";

	 update preram2010
	    set total_2009   = ene+feb+mar+abr+may+jun+jul+ago+sep+oct+nov+dic
	  where cod_ramo     = _cod_ramo
	    and tipo_mov     = '60';

end foreach

-- Calculo del % de sumatoria de montos de todos los bonos / prima suscrita

return 0, "Calculo del % comision" with resume;

foreach
	 select cod_ramo,
			tipo_mov,
			ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total_2009
	   into _cod_ramo,
			_tipo_mov,
			_ene2,_feb2,_mar2,_abr2,_may2,_jun2,_jul2,_ago2,_sep2,_oct2,_nov2,_dic2,_total_2009
	   from preram2010
	  where tipo_mov = "60"
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
  	   and tipo_mov = '61';

end foreach	 

-- Calculo de la Parte C1

return 0, "Calculo de la Parte C1" with resume;


call sp_preram7() returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if 		 				 

-- Calculo de la Parte C2

return 0, "Calculo de la Parte C2" with resume;

call sp_preram8() returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if 						 

-- Calculo de la Parte F  Salvamentos y Recuperos

return 0, "Calculo de la Parte F" with resume;


call sp_preram9() returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if

return 0, "Actualizacion Exitosa";

end procedure