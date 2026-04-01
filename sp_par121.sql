-- Procedimiento que verifica los montos de produccion contra los registros contables
-- 
-- Creado    : 09/12/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par121;		

create procedure "informix".sp_par121()
returning char(7),
		  dec(16,2),
		  dec(16,2),
		  dec(16,4),
		  dec(16,2),
		  dec(16,2),
		  dec(16,4);

define _no_poliza		char(10);
define _periodo			char(7);
define _porc_partic		dec(16,4);
define _porc_comis		dec(16,4);
define _prima_suscrita	dec(16,2);
define _comision		dec(16,2);
define _monto_cobro		dec(16,2);
define _comision_cobro	dec(16,2);

set isolation to dirty read;

create temp table tmp_global(
	periodo			char(7),
	prima_suscrita	dec(16,2),
	comision_prima	dec(16,2),
	monto_cobro		dec(16,2),
	comision_cobro	dec(16,2)
	) with no log;

foreach
 select e.periodo,
        e.prima_suscrita,
		e.no_poliza
   into _periodo,
        _prima_suscrita,
		_no_poliza
   from endedmae e, emipomae p
  where e.no_poliza       = p.no_poliza
    and e.periodo        >= "2002-11"
	and e.actualizado     = 1
	and p.sucursal_origen = "023"

		let _comision = 0.00;

		foreach
		 select porc_partic_agt,
				porc_comis_agt
		   into _porc_partic,
		        _porc_comis
		   from emipoagt
		  where no_poliza = _no_poliza

			let _porc_partic = _porc_partic / 100;
			let _porc_comis  = _porc_comis  / 100;
			let _comision    = _comision + (_prima_suscrita  *  _porc_partic * _porc_comis);

		end foreach
				      
		insert into tmp_global
		values (_periodo, _prima_suscrita, _comision, 0.00, 0.00);		        			


end foreach

foreach
 select e.periodo,
        e.prima_neta,
		e.no_poliza
   into _periodo,
        _monto_cobro,
		_no_poliza
   from cobredet e, emipomae p
  where e.no_poliza       = p.no_poliza
    and e.periodo        >= "2002-11"
	and e.actualizado     = 1
	and p.sucursal_origen = "023"
	and e.tipo_mov        in ("P", "N")

		let _comision_cobro = 0.00;

		foreach
		 select porc_partic_agt,
				porc_comis_agt
		   into _porc_partic,
		        _porc_comis
		   from emipoagt
		  where no_poliza = _no_poliza

			let _porc_partic    = _porc_partic / 100;
			let _porc_comis     = _porc_comis  / 100;
			let _comision_cobro = _comision_cobro + (_monto_cobro *  _porc_partic * _porc_comis);

		end foreach
				      
		insert into tmp_global
		values (_periodo, 0.00, 0.00, _monto_cobro, _comision_cobro);		        			

end foreach

foreach
 select periodo,
        sum(prima_suscrita),
		sum(comision_prima),
		sum(monto_cobro),
		sum(comision_cobro)
   into _periodo,
        _prima_suscrita,
		_comision,
		_monto_cobro,
		_comision_cobro
   from tmp_global
  group by periodo
  order by periodo
  
		if _prima_suscrita = 0.00 then
			let _porc_partic = 0.00;
		else
			let _porc_partic = _comision / _prima_suscrita * 100;
		end if

		if _monto_cobro = 0.00 then
			let _porc_comis  = 0.00;
		else 
			let _porc_comis  = _comision_cobro / _monto_cobro * 100;
		end if

		return _periodo,
		       _prima_suscrita,
			   _comision,
			   _porc_partic,
			   _monto_cobro,
			   _comision_cobro,
			   _porc_comis
			   with resume;

end foreach   		

drop table tmp_global;

end procedure