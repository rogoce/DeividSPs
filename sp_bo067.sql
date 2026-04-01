-- Procedimiento que carga los datos para el presupuesto del 2013
 
-- Creado     :	27/10/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo067;		

create procedure "informix".sp_bo067()
returning integer,
		  char(100);

define _cod_vendedor 	char(3);
define _cod_ramo	 	char(3);
define _tipo_mov		char(1);
define _tipo_poliza		char(1);
define _cod_agente		char(5);

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
define _cod_subramo     char(3);

-- Esquema Incial

set isolation to dirty read;

--{
return 0, "Eliminando tipo_mov = 1" with resume;
delete from sac999:preven2010 where tipo_mov = "1";

return 0, "Eliminando tipo_mov = 2" with resume;
delete from sac999:preven2010 where tipo_mov = "2";

return 0, "Eliminando tipo_mov = 3" with resume;
delete from sac999:preven2010 where tipo_mov = "3"; 

return 0, "Eliminando tipo_mov = 4" with resume;
delete from sac999:preven2010 where tipo_mov = "4";

return 0, "Eliminando tipo_mov = 5" with resume;
delete from sac999:preven2010 where tipo_mov = "5";

return 0, "Eliminando tipo_mov = 6" with resume;
delete from sac999:preven2010 where tipo_mov = "6";

return 0, "Eliminando tipo_mov = 7" with resume;
delete from sac999:preven2010 where tipo_mov = "7";

return 0, "Eliminando tipo_mov = 8" with resume;
delete from sac999:preven2010 where tipo_mov = "8";

return 0, "Eliminando tipo_mov = 9" with resume;
delete from sac999:preven2010 where tipo_mov = "9";

return 0, "Eliminando tipo_mov = -" with resume;
delete from sac999:preven2010 where tipo_mov = "-";

return 0, "Eliminando tipo_mov = *" with resume;
delete from sac999:preven2010 where tipo_mov = "*";

return 0, "Creando el Esquema Inicial" with resume;

--SET DEBUG FILE TO "sp_bo067.trc";
--TRACE ON;

foreach
 select cod_vendedor,
        cod_ramo,
		cod_agente
   into _cod_vendedor,
        _cod_ramo,
		_cod_agente
   from deivid:parpromo
  --where cod_ramo <> "008"
  group by 1, 2, 3
  
  
 if _cod_ramo = '018' then
  foreach
	   select cod_subramo
		 into _cod_subramo
		 from deivid:prdsubra
		where cod_ramo = _cod_ramo
		  and cod_subramo in('001','012')

		insert into sac999:preven2010
		values (_cod_vendedor, _cod_ramo, "1", "1", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente, _cod_subramo );

		insert into sac999:preven2010
		values (_cod_vendedor, _cod_ramo, "1", "2", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																										  
		insert into sac999:preven2010                                                                                                                                     
		values (_cod_vendedor, _cod_ramo, "2", "1", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																										  
		insert into sac999:preven2010                                                                                                                                     
		values (_cod_vendedor, _cod_ramo, "2", "2", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																										  
		insert into sac999:preven2010                                                                                                                                     
		values (_cod_vendedor, _cod_ramo, "7", "5", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																										  
		insert into sac999:preven2010                                                                                                                                     
		values (_cod_vendedor, _cod_ramo, "8", "5", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																										  
		insert into sac999:preven2010                                                                                                                                     
		values (_cod_vendedor, _cod_ramo, "9", "5", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
										                                                                                                                                   
		insert into sac999:preven2010                                                                                                                                      
		values (_cod_vendedor, _cod_ramo, "-", "-", null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, _cod_agente, _cod_subramo); 
										                                                                                                                                   
		insert into sac999:preven2010                                                                                                                                      
		values (_cod_vendedor, _cod_ramo, "*", "*", null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, _cod_agente, _cod_subramo); 
	
	end foreach
 elif _cod_ramo = '004' then
  foreach
	   select cod_subramo
		 into _cod_subramo
		 from deivid:prdsubra
		where cod_ramo = _cod_ramo
		  and cod_subramo in ('001','008','006','009')

		insert into sac999:preven2010
		values (_cod_vendedor, _cod_ramo, "1", "1", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente, _cod_subramo );

		insert into sac999:preven2010
		values (_cod_vendedor, _cod_ramo, "1", "2", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																										  
		insert into sac999:preven2010                                                                                                                                     
		values (_cod_vendedor, _cod_ramo, "2", "1", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																										  
		insert into sac999:preven2010                                                                                                                                     
		values (_cod_vendedor, _cod_ramo, "2", "2", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																										  
		insert into sac999:preven2010                                                                                                                                     
		values (_cod_vendedor, _cod_ramo, "7", "5", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																										  
		insert into sac999:preven2010                                                                                                                                     
		values (_cod_vendedor, _cod_ramo, "8", "5", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																										  
		insert into sac999:preven2010                                                                                                                                     
		values (_cod_vendedor, _cod_ramo, "9", "5", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
										                                                                                                                                   
		insert into sac999:preven2010                                                                                                                                      
		values (_cod_vendedor, _cod_ramo, "-", "-", null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, _cod_agente, _cod_subramo); 
										                                                                                                                                   
		insert into sac999:preven2010                                                                                                                                      
		values (_cod_vendedor, _cod_ramo, "*", "*", null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, _cod_agente, _cod_subramo); 
	
	end foreach
	else
		let _cod_subramo = '001';
			insert into sac999:preven2010
			values (_cod_vendedor, _cod_ramo, "1", "1", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente, _cod_subramo );

			insert into sac999:preven2010
			values (_cod_vendedor, _cod_ramo, "1", "2", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																											  
			insert into sac999:preven2010                                                                                                                                     
			values (_cod_vendedor, _cod_ramo, "2", "1", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																											  
			insert into sac999:preven2010                                                                                                                                     
			values (_cod_vendedor, _cod_ramo, "2", "2", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																											  
			insert into sac999:preven2010                                                                                                                                     
			values (_cod_vendedor, _cod_ramo, "7", "5", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																											  
			insert into sac999:preven2010                                                                                                                                     
			values (_cod_vendedor, _cod_ramo, "8", "5", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																											  
			insert into sac999:preven2010                                                                                                                                     
			values (_cod_vendedor, _cod_ramo, "9", "5", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);
																																											   
			insert into sac999:preven2010                                                                                                                                      
			values (_cod_vendedor, _cod_ramo, "-", "-", null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, _cod_agente, _cod_subramo); 
																																											   
			insert into sac999:preven2010                                                                                                                                      
			values (_cod_vendedor, _cod_ramo, "*", "*", null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, _cod_agente, _cod_subramo); 
	end if
	
end foreach

-- Calculo de la Prima Suscrita Sin Fronting

return 0, "Calculo de la Prima Suscrita" with resume;

--{
call sp_bo068() returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if

/*call sp_bo0682() returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if*/
--}

-- Calculo de Totales Verticales

return 0, "Calculo de Totales Verticales" with resume;

delete from sac999:preven2010 where tipo_mov = "3"; 

foreach
 select cod_vendedor,
        cod_ramo,
		cod_agente,
		cod_subra,
		sum(ene),
		sum(feb),
		sum(mar),
		sum(abr),
		sum(may),
		sum(jun),
		sum(jul),
		sum(ago),
		sum(sep),
		sum(oct),
		sum(nov),
		sum(dic)
   into _cod_vendedor,
        _cod_ramo,
		_cod_agente,
		_cod_subramo,
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
   from sac999:preven2010
  group by 1, 2, 3, 4

	insert into sac999:preven2010
	values (_cod_vendedor, _cod_ramo, "3", "3", _ene, _feb, _mar, _abr, _may, _jun, _jul, _ago, _sep, _oct, _nov, _dic, 0.00, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);

end foreach

-- Calculo de Totales Horizontales

return 0, "Calculo de Totales Horizontales" with resume;

foreach
 select cod_vendedor,
        cod_ramo,
		cod_agente,
		tipo_mov,
		tipo_poliza,
		cod_subra,
		(ene + feb + mar + abr + may + jun + jul + ago + sep + oct + nov + dic),
		total_2008
   into _cod_vendedor,
        _cod_ramo,
		_cod_agente,
		_tipo_mov,
		_tipo_poliza,
		_cod_subramo,
		_total_2009,
		_total_2008
   from sac999:preven2010

	-- Polizas Nuevas

	let _nueva_porc =  0.00;

	if _tipo_mov    = "1" and
	   _tipo_poliza = "1" then 

		if _total_2008 = 0 then
			let _nueva_porc =  0.00;
		else
			let _nueva_porc =  ((_total_2009 - _total_2008) / _total_2008) * 100;
		end if

	end if

	update sac999:preven2010
	   set total_2009   = _total_2009,
	       nueva_porc   = _nueva_porc
	 where cod_vendedor = _cod_vendedor
	   and cod_ramo     = _cod_ramo
	   and tipo_mov     = _tipo_mov
	   and tipo_poliza  = _tipo_poliza
	   and cod_agente	= _cod_agente
	   and cod_subra    = _cod_subramo;

end foreach

-- Calculo del % de Cancelacion de las Renovaciones

return 0, "Calculo del % de Cancelacion de las Renovaciones" with resume;

foreach
 select cod_vendedor,
        cod_ramo,
		cod_agente,
		tipo_mov,
		tipo_poliza,
		total_2009,
		cod_subra
   into _cod_vendedor,
        _cod_ramo,
		_cod_agente,
		_tipo_mov,
		_tipo_poliza,
		_total_2009,
		_cod_subramo
   from sac999:preven2010
  where tipo_mov    = "2"
    and tipo_poliza = "2"

	select total_2009
	  into _total_2008
	  from sac999:preven2010
	 where cod_vendedor = _cod_vendedor
	   and cod_ramo     = _cod_ramo
	   and tipo_mov     = "1"
	   and tipo_poliza  = "2"
	   and cod_agente   = _cod_agente
	   and cod_subra	= _cod_subramo;

	if _total_2008 = 0 then
		let _nueva_porc =  0.00;
	else
		let _nueva_porc =  (_total_2009 / _total_2008) * -100;
	end if

	if _nueva_porc > 100 then
		let _nueva_porc =  100;
	end if

	update sac999:preven2010
	   set nueva_porc   = _nueva_porc
	 where cod_vendedor = _cod_vendedor
	   and cod_ramo     = _cod_ramo
	   and tipo_mov     = _tipo_mov
	   and tipo_poliza  = _tipo_poliza
	   and cod_agente   = _cod_agente
	   and cod_subra	= _cod_subramo;

end foreach

-- Renovaciones 2010

return 0, "Renovaciones 2010" with resume;

delete from sac999:preven2010 where tipo_mov = "4"; 

foreach
 select cod_vendedor,
        cod_ramo,
		cod_agente,
		cod_subra,
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
		dic,
		total_2009
   into _cod_vendedor,
        _cod_ramo,
		_cod_agente,
		_cod_subramo,
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
		_dic,
		_total_2009
   from sac999:preven2010
  where tipo_mov    = "3"
    and tipo_poliza = "3"

	if _cod_ramo = "020" then

		let _ene 		= 0.00;
		let _feb 		= 0.00;
		let _mar 		= 0.00;
		let _abr 		= 0.00;
		let _may 		= 0.00;
		let _jun 		= 0.00;
		let _jul 		= 0.00;
		let _ago 		= 0.00;
		let _sep 		= 0.00;
		let _oct 		= 0.00;
		let _nov 		= 0.00;
		let _dic 		= 0.00;
		let _total_2009 = 0.00;

	else

		select nueva_porc
		  into _nueva_porc
		  from sac999:preven2010
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = "2"
		   and tipo_poliza  = "2"
		   and cod_agente   = _cod_agente
		   and cod_subra    = _cod_subramo;

		if _total_2009 = 0 then

			let _porc_ene = 0.00;
			let _porc_feb = 0.00;
			let _porc_mar = 0.00;
			let _porc_abr = 0.00;
			let _porc_may = 0.00;
			let _porc_jun = 0.00;
			let _porc_jul = 0.00;
			let _porc_ago = 0.00;
			let _porc_sep = 0.00;
			let _porc_oct = 0.00;
			let _porc_nov = 0.00;
			let _porc_dic = 0.00;

		else

			let _porc_ene = _ene / _total_2009;
			let _porc_feb = _feb / _total_2009;
			let _porc_mar = _mar / _total_2009;
			let _porc_abr = _abr / _total_2009;
			let _porc_may = _may / _total_2009;
			let _porc_jun = _jun / _total_2009;
			let _porc_jul = _jul / _total_2009;
			let _porc_ago = _ago / _total_2009;
			let _porc_sep = _sep / _total_2009;
			let _porc_oct = _oct / _total_2009;
			let _porc_nov = _nov / _total_2009;
			let _porc_dic = _dic / _total_2009;

		end if

		let _total_2009 = _total_2009 - (_total_2009 * _nueva_porc / 100);

		let _ene = _porc_ene * _total_2009;
		let _feb = _porc_feb * _total_2009;
		let _mar = _porc_mar * _total_2009;
		let _abr = _porc_abr * _total_2009;
		let _may = _porc_may * _total_2009;
		let _jun = _porc_jun * _total_2009;
		let _jul = _porc_jul * _total_2009;
		let _ago = _porc_ago * _total_2009;
		let _sep = _porc_sep * _total_2009;
		let _oct = _porc_oct * _total_2009;
		let _nov = _porc_nov * _total_2009;
		let _dic = _porc_dic * _total_2009;
		
	end if

	insert into sac999:preven2010
	values (_cod_vendedor, _cod_ramo, "4", "4", _ene, _feb, _mar, _abr, _may, _jun, _jul, _ago, _sep, _oct, _nov, _dic, _total_2009, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);

end foreach

-- Nuevas 2010

return 0, "Nuevas 2010" with resume;

delete from sac999:preven2010 where tipo_mov = "5"; 

foreach
 select cod_vendedor,
        cod_ramo,
		cod_agente,
		cod_subra,
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
		dic,
		total_2009,
		nueva_porc
   into _cod_vendedor,
        _cod_ramo,
		_cod_agente,
		_cod_subramo,
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
		_dic,
		_total_2009,
		_nueva_porc
   from sac999:preven2010
  where tipo_mov    = "1"
    and tipo_poliza = "1"


	let _nueva_porc = 10;

	{
	if _nueva_porc < 15 then
		let _nueva_porc = 15;
	end if

	if _nueva_porc > 20 then
		let _nueva_porc = 20;
	end if
	}

	let _ene2 		= _ene        * _nueva_porc / 100;
	let _feb2 		= _feb        * _nueva_porc / 100;
	let _mar2 		= _mar        * _nueva_porc / 100;
	let _abr2 		= _abr        * _nueva_porc / 100;
	let _may2 		= _may        * _nueva_porc / 100;
	let _jun2 		= _jun        * _nueva_porc / 100;
	let _jul2 		= _jul        * _nueva_porc / 100;
	let _ago2 		= _ago        * _nueva_porc / 100;
	let _sep2 		= _sep        * _nueva_porc / 100;
	let _oct2 		= _oct        * _nueva_porc / 100;
	let _nov2 		= _nov        * _nueva_porc / 100;
	let _dic2 		= _dic 		  * _nueva_porc / 100;
	let _total_2    = _total_2009 * _nueva_porc / 100;

	let _ene 		= _ene        + _ene2;
	let _feb 		= _feb        + _feb2;
	let _mar 		= _mar        + _mar2;
	let _abr 		= _abr        + _abr2;
	let _may 		= _may        + _may2;
	let _jun 		= _jun        + _jun2;
	let _jul 		= _jul        + _jul2;
	let _ago 		= _ago        + _ago2;
	let _sep 		= _sep        + _sep2;
	let _oct 		= _oct        + _oct2;
	let _nov 		= _nov        + _nov2;
	let _dic 		= _dic 		  + _dic2;
	let _total_2009 = _total_2009 + _total_2;

	insert into sac999:preven2010
	values (_cod_vendedor, _cod_ramo, "5", "4", _ene, _feb, _mar, _abr, _may, _jun, _jul, _ago, _sep, _oct, _nov, _dic, _total_2009, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);

end foreach

-- Totales 2010

return 0, "Totales 2010" with resume;

delete from sac999:preven2010 where tipo_mov = "6"; 

foreach
 select cod_vendedor,
        cod_ramo,
		cod_agente,
		cod_subra,
		sum(ene),
		sum(feb),
		sum(mar),
		sum(abr),
		sum(may),
		sum(jun),
		sum(jul),
		sum(ago),
		sum(sep),
		sum(oct),
		sum(nov),
		sum(dic),
		sum(total_2009)
   into _cod_vendedor,
        _cod_ramo,
		_cod_agente,
		_cod_subramo,
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
		_dic,
		_total_2009
   from sac999:preven2010
  where tipo_mov    in ("4", "5")
  group by 1, 2, 3, 4

	insert into sac999:preven2010
	values (_cod_vendedor, _cod_ramo, "6", "4", _ene, _feb, _mar, _abr, _may, _jun, _jul, _ago, _sep, _oct, _nov, _dic, _total_2009, 0.00, 0.00, 0.00, _cod_agente,_cod_subramo);

end foreach

return 0, "Actualizacion Exitosa";

end procedure