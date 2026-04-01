-- Distribucion de Reaseguro de Cambio de Reaseguro mal hecho

-- Creado    : 13/09/2002 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/09/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par56;

create procedure "informix".sp_par56()
returning char(7),
          char(10),
		  dec(16,2),
		  char(5),
		  char(50),
		  dec(16,2),
		  dec(16,6),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(20),
		  char(3),
		  char(50),
		  char(5),
		  char(3),
		  char(10),
		  char(5);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_unidad   	char(5);
define _cantidad    	integer;
define _cod_cober_reas	char(3);
define _orden			integer;
define _prima_total		dec(16,2);
define _prima_contrato  dec(16,2);
define _prima_endoso	dec(16,2);
define _prima_real		dec(16,2);
define _prima_ajuste	dec(16,2);
define _porc_partic		dec(16,6);
define _cod_contrato	char(5);
define _nomb_contrato	char(50);
define _periodo			char(7);
define _no_factura      char(10);
define _prima_suscrita  dec(16,2);
define _no_documento	char(20);
define _cod_ramo		char(3);
define _nomb_ramo		char(50);

{
create temp table tmp_reas(
periodo			char(7),
cod_ramo		char(3),
no_documento	char(20),
no_factura		char(10),
cod_contrato	char(3),
prima_suscrita	dec(16,2),
prima_contrato	dec(16,2),
porc_partic		dec(16,6),
prima_endoso,
prima_real,
prima_ajuste,
}

--set debug file to "sp_par56.trc";
--trace on;

foreach
 select	no_poliza,
        no_endoso,
		no_factura,
		periodo,
		prima_suscrita
   into _no_poliza,
        _no_endoso,
		_no_factura,
		_periodo,
		_prima_suscrita
   from endedmae
  where cod_endomov    = "017"
	and periodo       >= "2001-01"
	and periodo       <= "2002-07"
    and actualizado    = 1
	and prima_suscrita <> 0.00
--	and no_factura     = "01-125480"

	select no_documento,
	       cod_ramo
	  into _no_documento,
	       _cod_ramo
	  from emipomae
	 where no_poliza =  _no_poliza;

	select nombre
	  into _nomb_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;
	
	foreach
	 select	no_unidad
	   into	_no_unidad
	   from	endeduni
	  where	no_poliza = _no_poliza
	    and no_endoso = _no_endoso

		select count(*)
		  into _cantidad
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad;

		if _cantidad = 0 then
			continue foreach;
		end if

		foreach
		 select	cod_cober_reas,
		        orden,
				porc_partic_prima,
				prima,
				cod_contrato
		   into	_cod_cober_reas,
		        _orden,
				_porc_partic,
				_prima_endoso,
				_cod_contrato
		   from emifacon
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso
		    and no_unidad = _no_unidad
		  order by 2

			select nombre
			  into _nomb_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;
			
			select sum(prima)
			  into _prima_total
			  from emifacon
		 	 where no_poliza      = _no_poliza
		       and no_endoso      < _no_endoso
		       and no_unidad      = _no_unidad
		       and cod_cober_reas = _cod_cober_reas;

			if _prima_total is null then
				let _prima_total = 0.00;
			end if

			select sum(prima)
			  into _prima_contrato
			  from emifacon
		 	 where no_poliza      = _no_poliza
		       and no_endoso      < _no_endoso
		       and no_unidad      = _no_unidad
		       and cod_cober_reas = _cod_cober_reas
			   and cod_contrato   = _cod_contrato;
			   	
--		       and orden          = _orden;

			if _prima_contrato is null then
				let _prima_contrato = 0.00;
			end if

			let _prima_real   = (_porc_partic / 100 * _prima_total) - _prima_contrato;
			let _prima_ajuste = _prima_real - _prima_endoso;			

			return _periodo,
			       _no_factura,
				   _prima_suscrita,
				   _cod_contrato,
				   _nomb_contrato,
				   _prima_contrato,
				   _porc_partic,
				   _prima_endoso,
				   _prima_real,
				   _prima_ajuste,
				   _no_documento,
				   _cod_ramo,
				   _nomb_ramo,
				   _no_unidad,
				   _cod_cober_reas,
				   _no_poliza,
				   _no_endoso
				   with resume;

		end foreach

	end foreach

end foreach

end procedure;



