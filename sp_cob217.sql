-- Verificacion de Montos de Cobredet Vs Cobasien

-- Creado    : 04/09/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob217;

create procedure "informix".sp_cob217()
returning char(10),
          smallint,
          dec(16,2),
          dec(16,2);

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
define _monto2			dec(16,2);
define _prima_cob_acu	dec(16,2);
define _cantidad		smallint;

define _no_remesa		char(10);
define _renglon			smallint;

define _error			integer;
define _error_desc		char(50);

create temp table tmp_cobros(
no_remesa	char(10),
renglon		smallint,
monto1		dec(16,2),
monto2		dec(16,2)
) with no log;

foreach
 select no_poliza,
        doc_remesa,
        prima_neta,
		periodo,
		no_remesa,
		renglon
   into _no_poliza,
        _no_documento,
   		_monto,
		_periodo,
		_no_remesa,
		_renglon
   from cobredet
  where periodo[1,4] = 2009
	and actualizado  = 1
	and tipo_mov     in ("P", "N")
--	and periodo      = "2009-08"
	
	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then
		continue foreach;
	end if

	insert into tmp_cobros
	values (_no_remesa, _renglon, _monto, 0.00);

{
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
}
end foreach

foreach
 select cuenta,
        periodo,
		centro_costo,
        (credito - debito),
		no_remesa,
		renglon
   into _cuenta,
        _periodo,
		_centro_costo,
        _monto,
		_no_remesa,
		_renglon
   from cobasien
  where periodo[1,4] >= 2009
--	and periodo      = "2009-08"
	and (cuenta       like "131%" or
         cuenta       like "144%")

	insert into tmp_cobros
	values (_no_remesa, _renglon, 0.00, _monto);
{
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
}

end foreach

foreach
 select no_remesa,
        renglon,
		sum(monto1),
		sum(monto2)
   into _no_remesa,
        _renglon,
		_monto,
		_monto2
   from tmp_cobros
  group by 1, 2

	if _monto <> _monto2 then

		return _no_remesa,
		       _renglon,
			   _monto,
			   _monto2
			   with resume;

	end if

end foreach

drop table tmp_cobros;

return "",
       0,
	   0.00,
	   0.00;

end procedure