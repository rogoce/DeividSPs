-- Procedimiento que carga la tabla para el presupuesto de ventas 

-- Creado    : 09/03/2010 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par299;

create procedure "informix".sp_par299(a_ano char(4), a_cod_vendedor char(3) )
returning integer,
          char(50);

define _cod_vendedor	char(3);
define _cod_agente		char(5);
define _cod_ramo		char(3);

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
define _monto_suma		dec(16,2);

define _monto_total		dec(16,2);
define _monto_mensual	dec(16,2);
define _monto_calculado	dec(16,2);
define _monto_ajuste	dec(16,2);


define _cantidad		smallint;
define _ano				char(4);
define _cod_subramo     char(3);

let _ano = a_ano;

--SET DEBUG FILE TO "sp_sp_par299.trc";      
--TRACE ON;     
                                                                
delete from deivid_bo:preventas
 where periodo[1,4] = _ano and cod_vendedor = a_cod_vendedor;

-- Se actualiza el codigo de vendedor 

{
foreach
 select	cod_vendedor,
        cod_agente
   into _cod_vendedor,
        _cod_agente
   from deivid_bo:actuario_2018
   --from sac999:preven2010
   --from deivid_tmp:preven2012
   where cod_vendedor = a_cod_vendedor
     and ano 		  =  a_ano
  group by 1, 2
  order by 1, 2

	update deivid:agtagent
	   set cod_vendedor = _cod_vendedor
	 where cod_agente   = _cod_agente;
	 
	update sac999:preven2010
	   set cod_vendedor = _cod_vendedor
	 where cod_agente   = _cod_agente;

end foreach
return 0, "Actualizacion Exitosa";
}
--trace on;

-- Ventas Nuevas

foreach
 select	cod_vendedor,
        cod_agente,
		cod_ramo,
		total_2009,
		cod_subra
   into _cod_vendedor,
        _cod_agente,
		_cod_ramo,
		_monto_total,
		_cod_subramo
	from sac999:preven2010		
   --from deivid_tmp:preven2012
  where tipo_mov = "8"
    and cod_vendedor = a_cod_vendedor
    --and cod_agente   = "00081"
    --and cod_ramo     = "001"

	-- Para calcular el % de ventas de cada mes

	select ene,
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
	  into _ene,
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
		   _monto_suma
	  from sac999:preven2010
	 where cod_vendedor = _cod_vendedor
	   and cod_ramo    = _cod_ramo
	   and tipo_mov    = "1"
	   and tipo_poliza = "1"
       and cod_agente  = _cod_agente 
	   and cod_subra = _cod_subramo;

	let _monto_mensual = _ene + _feb + _mar + _abr + _may + _jun + _jul + _ago + _sep + _oct + _nov + _dic;	

	if _ene = 0 and _feb = 0 and _mar = 0 and _abr = 0 and _may = 0 and _jun = 0 and _jul = 0 and _ago = 0 and _sep = 0 and _oct = 0 and _nov = 0 and _dic = 0 or _monto_mensual is null then -- Todos los meses son 0

		let _monto_mensual   = _monto_total   / 12;
		let _monto_calculado = _monto_mensual * 12;
		let _monto_ajuste    = _monto_total   - _monto_calculado;

		let	_ene = _monto_mensual;
		let	_feb = _monto_mensual;
		let	_mar = _monto_mensual;
		let	_abr = _monto_mensual;
		let	_may = _monto_mensual;
		let	_jun = _monto_mensual;
		let	_jul = _monto_mensual;
		let	_ago = _monto_mensual;
		let	_sep = _monto_mensual;
		let	_oct = _monto_mensual;
		let	_nov = _monto_mensual;
		let	_dic = _monto_mensual + _monto_ajuste;

	else
		if _ene >  _monto_suma or _feb >  _monto_suma or _mar >  _monto_suma or _abr >  _monto_suma or _may >  _monto_suma or _jun >  _monto_suma or _jul >  _monto_suma or _ago >  _monto_suma or _sep >  _monto_suma or _oct >  _monto_suma or _nov >  _monto_suma or _dic >  _monto_suma then 
			let _monto_suma = 0;
		end if

		if abs(_monto_suma) < 10  then
			let _monto_suma = 0;
		end if
		
		if _monto_suma < 0  then
			let _monto_suma = 0;
		end if

		if _monto_suma = 0 then

			let _monto_mensual   = _monto_total   / 12;
			let _monto_calculado = _monto_mensual * 12;
			let _monto_ajuste    = _monto_total   - _monto_calculado;

			let	_ene = _monto_mensual;
			let	_feb = _monto_mensual;
			let	_mar = _monto_mensual;
			let	_abr = _monto_mensual;
			let	_may = _monto_mensual;
			let	_jun = _monto_mensual;
			let	_jul = _monto_mensual;
			let	_ago = _monto_mensual;
			let	_sep = _monto_mensual;
			let	_oct = _monto_mensual;
			let	_nov = _monto_mensual;
			let	_dic = _monto_mensual + _monto_ajuste;

		else

			let _ene = _ene / _monto_suma *	_monto_total;
			let _feb = _feb / _monto_suma *	_monto_total;
			let _mar = _mar / _monto_suma *	_monto_total;
			let _abr = _abr / _monto_suma *	_monto_total;
			let _may = _may / _monto_suma *	_monto_total;
			let _jun = _jun / _monto_suma *	_monto_total;
			let _jul = _jul / _monto_suma *	_monto_total;
			let _ago = _ago / _monto_suma *	_monto_total;
			let _sep = _sep / _monto_suma *	_monto_total;
			let _oct = _oct / _monto_suma *	_monto_total;
			let _nov = _nov / _monto_suma *	_monto_total;
			let _dic = _dic / _monto_suma *	_monto_total;
		
			let _monto_calculado = _ene + _feb + _mar + _abr + _may + _jun + _jul + _ago + _sep + _oct + _nov + _dic;	
			let _monto_ajuste    = _monto_total   - _monto_calculado;
			let	_dic             = _dic + _monto_ajuste;

		end if

	end if

	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-01", "N", _ene,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-02", "N", _feb,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-03", "N", _mar,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-04", "N", _abr,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-05", "N", _may,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-06", "N", _jun,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-07", "N", _jul,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-08", "N", _ago,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-09", "N", _sep,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-10", "N", _oct,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-11", "N", _nov,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-12", "N", _dic,_cod_subramo);

end foreach

-- Ventas Renovadas

foreach
 select	cod_vendedor,
        cod_agente,
		cod_ramo,
		total_2009,
		cod_subra
   into _cod_vendedor,
        _cod_agente,
		_cod_ramo,
		_monto_total,
		_cod_subramo
   from sac999:preven2010		
   --from deivid_tmp:preven2012
  where tipo_mov = "7"
  and cod_vendedor = a_cod_vendedor
  
  -- Para calcular el % de ventas de cada mes

	select ene,
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
	  into _ene,
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
		   _monto_suma
	  from sac999:preven2010
	 where cod_vendedor = _cod_vendedor 
	   and cod_ramo    = _cod_ramo
	   and tipo_mov    = "1"
	   and tipo_poliza = "2"
       and cod_agente  = _cod_agente
	   and cod_subra = _cod_subramo;
  
	let _monto_mensual = _ene + _feb + _mar + _abr + _may + _jun + _jul + _ago + _sep + _oct + _nov + _dic;	

	if _ene = 0 and _feb = 0 and _mar = 0 and _abr = 0 and _may = 0 and _jun = 0 and _jul = 0 and _ago = 0 and _sep = 0 and _oct = 0 and _nov = 0 and _dic = 0 or _monto_mensual is null then -- Todos los meses son 0

		let _monto_mensual   = _monto_total   / 12;
		let _monto_calculado = _monto_mensual * 12;
		let _monto_ajuste    = _monto_total   - _monto_calculado;

		let	_ene = _monto_mensual;
		let	_feb = _monto_mensual;
		let	_mar = _monto_mensual;
		let	_abr = _monto_mensual;
		let	_may = _monto_mensual;
		let	_jun = _monto_mensual;
		let	_jul = _monto_mensual;
		let	_ago = _monto_mensual;
		let	_sep = _monto_mensual;
		let	_oct = _monto_mensual;
		let	_nov = _monto_mensual;
		let	_dic = _monto_mensual + _monto_ajuste;

	else
		if _ene >  _monto_suma or _feb >  _monto_suma or _mar >  _monto_suma or _abr >  _monto_suma or _may >  _monto_suma or _jun >  _monto_suma or _jul >  _monto_suma or _ago >  _monto_suma or _sep >  _monto_suma or _oct >  _monto_suma or _nov >  _monto_suma or _dic >  _monto_suma then 
			let _monto_suma = 0;
		end if
		
		if abs(_monto_suma) < 10 then
			let _monto_suma = 0;
		end if
		
		if _monto_suma < 0  then
			let _monto_suma = 0;
		end if

		if _monto_suma = 0 then

			let _monto_mensual   = _monto_total   / 12;
			let _monto_calculado = _monto_mensual * 12;
			let _monto_ajuste    = _monto_total   - _monto_calculado;

			let	_ene = _monto_mensual;
			let	_feb = _monto_mensual;
			let	_mar = _monto_mensual;
			let	_abr = _monto_mensual;
			let	_may = _monto_mensual;
			let	_jun = _monto_mensual;
			let	_jul = _monto_mensual;
			let	_ago = _monto_mensual;
			let	_sep = _monto_mensual;
			let	_oct = _monto_mensual;
			let	_nov = _monto_mensual;
			let	_dic = _monto_mensual + _monto_ajuste;

		else

			let _ene = _ene / _monto_suma *	_monto_total;
			let _feb = _feb / _monto_suma *	_monto_total;
			let _mar = _mar / _monto_suma *	_monto_total;
			let _abr = _abr / _monto_suma *	_monto_total;
			let _may = _may / _monto_suma *	_monto_total;
			let _jun = _jun / _monto_suma *	_monto_total;
			let _jul = _jul / _monto_suma *	_monto_total;
			let _ago = _ago / _monto_suma *	_monto_total;
			let _sep = _sep / _monto_suma *	_monto_total;
			let _oct = _oct / _monto_suma *	_monto_total;
			let _nov = _nov / _monto_suma *	_monto_total;
			let _dic = _dic / _monto_suma *	_monto_total;

			let _monto_calculado = _ene + _feb + _mar + _abr + _may + _jun + _jul + _ago + _sep + _oct + _nov + _dic;	
			let _monto_ajuste    = _monto_total   - _monto_calculado;
			let	_dic             = _dic + _monto_ajuste;

		end if

	end if

	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-01", "R", _ene,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-02", "R", _feb,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-03", "R", _mar,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-04", "R", _abr,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-05", "R", _may,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-06", "R", _jun,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-07", "R", _jul,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-08", "R", _ago,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-09", "R", _sep,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-10", "R", _oct,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-11", "R", _nov,_cod_subramo);
	call sp_par300(_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-12", "R", _dic,_cod_subramo);

end foreach

-- Actualiza las metas de cobros

update deivid_bo:preventas
   set cobros = ventas_total * 0.95;

return 0, "Actualizacion Exitosa";

end procedure


