-- Procedimiento que crea los montos cobrados

-- Creado    : 04/09/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo059;

create procedure "informix".sp_bo059()
returning integer,
          char(50);

define _no_poliza		char(10);
define _no_documento	char(20);
define _centro_costo	char(3);
define _cuenta			char(25);
define _enlace			char(10);
define _periodo			char(7);
define _cod_tipoprod	char(3);

define _ano				char(4);
define _mes				smallint;
define _cia_comp		char(3);

define _monto			dec(16,2);
define _prima_cob_acu	dec(16,2);
define _cantidad		smallint;

define _error			integer;
define _error_desc		char(50);
define _ano_fiscal		smallint;

select par_anofiscal
  into _ano_fiscal
  from cglparam;

delete from sac:cglsaldocob;

foreach
 select no_poliza,
        doc_remesa,
        prima_neta,
		periodo
   into _no_poliza,
        _no_documento,
   		_monto,
		_periodo
   from cobredet
  where periodo[1,4] >= _ano_fiscal
	and actualizado   = 1
	and tipo_mov      in ("P", "N")
	
{
	if _no_poliza is null then
		
		let _no_poliza = sp_sis21(_no_documento);

		select vigencia_inic,
		       vigencia_final
		  into _vigen_ini,
		       _vigen_fin
		  from emipomae
		 where no_poliza = _no_poliza;

	end if
}

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then
		continue foreach;
	end if

	call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

	if _error <> 0 then

		if _error_desc is null then
			let _error_desc = "Error en Centro Costo Poliza " || _no_poliza;
		end if

		return _error, _error_desc;

	end if

	let _cuenta = sp_sis15('PAPXCSD', '01', _no_poliza);
	let _enlace = _cuenta[4,25];

	select count(*)
	  into _cantidad
	  from sac:cglsaldocob
	 where cia_comp = "001"
	   and ano      = _periodo[1,4]
	   and periodo  = _periodo[6,7]
	   and enlace   = _enlace
	   and ccosto	= _centro_costo;

	if _cantidad = 0 then

		insert into sac:cglsaldocob(cia_comp, ano, periodo, enlace, ccosto, prima_cobrada, prima_cobrada_acu)
		values ("001", _periodo[1,4], _periodo[6,7], _enlace, _centro_costo, _monto, 0.00);

	else

		update sac:cglsaldocob
		   set prima_cobrada = prima_cobrada + _monto
		 where cia_comp      = "001"
		   and ano           = _periodo[1,4]
		   and periodo       = _periodo[6,7]
		   and enlace        = _enlace
		   and ccosto	     = _centro_costo;

	end if

end foreach

foreach
 select cia_comp,
        ano,
		enlace,
		ccosto
   into _cia_comp,
        _ano,
		_enlace,
		_centro_costo
   from sac:cglsaldocob
  group by 1, 2, 3, 4
  order by 1, 2, 3, 4

	let _prima_cob_acu = 0.00;

	for _mes = 1 to 12

		select prima_cobrada
		  into _monto
	      from sac:cglsaldocob
	     where cia_comp = _cia_comp
	       and ano      = _ano
		   and periodo  = _mes
	       and enlace   = _enlace
	   	   and ccosto   = _centro_costo;

		if _monto is null then

			let _monto = 0.00;

			insert into sac:cglsaldocob(cia_comp, ano, periodo, enlace, ccosto, prima_cobrada, prima_cobrada_acu)
			values ("001", _ano, _mes, _enlace, _centro_costo, 0.00, 0.00);

		end if

		let _prima_cob_acu = _prima_cob_acu + _monto;

		update sac:cglsaldocob
		   set prima_cobrada_acu = _prima_cob_acu
		 where cia_comp          = _cia_comp
		   and ano               = _ano
		   and periodo           = _mes
		   and enlace            = _enlace
		   and ccosto            = _centro_costo;

	end for

end foreach

return 0, "Actualizacion Exitosa";

end procedure