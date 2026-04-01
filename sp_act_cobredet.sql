-- Actualizacion de valores de Nuevas y Renovadas para tabla cobredet


-- Creado    : 25/05/2015 - Autor: Armando Moreno

drop procedure sp_act_cobredet;

create procedure "informix".sp_act_cobredet(a_periodo char(7))
returning integer,
          char(50);

define _no_poliza		char(10);
define _no_remesa       char(10);
define _no_endoso		char(5);
define _cod_endomov		char(3);
define _prima_suscrita	dec(16,2);
define _cod_perpago     char(3);

define _nueva_renov		char(1);
define _cod_ramo		char(3);
define _vigencia_inic	date;
define _vigencia_final	date;
define _fecha_recibo    date;
define _dias			integer;

define _ano1			integer;
define _renglon			integer;
define _ano2			dec(16,1);
define _ano_bis1		integer;
define _ano_bis2		dec(16,2);
define _dias_dif		smallint;

define _poliza_nueva	smallint;
define _poliza_renovada	smallint;
define _pbs_nueva_nueva	dec(16,2);
define _pbs_nueva_canc	dec(16,2);
define _pbs_nueva_neto	dec(16,2);
define _pbs_renov_nueva	dec(16,2);
define _pbs_renov_canc	dec(16,2);
define _pbs_renov_neto	dec(16,2);

define _emi_ano			smallint;
define _meses_por       smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_isam || " " || trim(_error_desc);
end exception

let _dias = 0;

foreach with hold

 select no_poliza,
        no_remesa,
		renglon,
		fecha
   into _no_poliza,
        _no_remesa,
		_renglon,
		_fecha_recibo
   from cobredet
  where actualizado  = 1
    and	periodo      = a_periodo
	and nueva_renov  = '0'
	and tipo_mov     in('P','N')
--	and no_remesa    = '886787'
	--and renglon      = 475

	begin work;
	select nueva_renov,
	       cod_ramo,
		   vigencia_inic,
		   cod_perpago
	  into _nueva_renov,
	       _cod_ramo,
		   _vigencia_inic,
		   _cod_perpago
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo = "018" then -- Ramo de Salud
	
		let _dias = _fecha_recibo - _vigencia_inic;
		
		if _dias > 365 then
			let _nueva_renov = "R";
		else
			let _nueva_renov = "N";
		end if			

	end if

	update cobredet
	   set nueva_renov = _nueva_renov
	 where no_remesa   = _no_remesa
       and renglon     = _renglon;	 

	commit work;
end foreach

end

return 0, "Actualizacion Exitosa";

end procedure
