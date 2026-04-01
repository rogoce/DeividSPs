--fianzas emitidas de 10/2002 a 12/2002 para apadea.
--creado demetrio hurtado	12/04/2003
--mod 	 armando moreno		14/04/2003

drop procedure sp_pro114;

create procedure sp_pro114(a_compania char(3), a_periodo char(7))
returning char(20),
          char(50),
		  char(100),
		  date,
		  date,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(50),
		  char(50);

define _no_poliza		char(10);
define _no_endoso		char(10);
define _no_unidad		char(5);
define _vigencia_inic	date;
define _vigencia_final	date;
define _no_documento	char(20);
define _cod_cliente		char(10);
define _nombre_cliente	char(100);
define _suma_asegurada	dec(16,2);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _nombre_subramo	char(50);
define _porc_retencion	dec(16,2);
define _nombre_compania char(50);
define _porc_partic_suma dec(16,2);
define _cod_contrato	char(5);
define _tipo_contrato	smallint;
define _cod_cober_reas	char(3);
define _orden			smallint;
define _cod_coasegur	char(3);
define _nombre_reas		char(50);
define _porc_partic		dec(16,2);
define _nombre_cont		char(50);

set isolation to dirty read;

LET _nombre_compania = sp_sis01(a_compania);

foreach
 select p.no_documento,
		e.vigencia_inic,
		e.vigencia_final,
		p.cod_ramo,
		p.cod_subramo,
		e.no_poliza,
		e.no_endoso,
		p.cod_contratante
   into	_no_documento,
		_vigencia_inic,
		_vigencia_final,
		_cod_ramo,
		_cod_subramo,
		_no_poliza,
		_no_endoso,
		_cod_cliente
   from endedmae e, emipomae p
  where e.no_poliza      = p.no_poliza
    and p.cod_ramo       = "008"
    and e.actualizado    = 1
    and e.periodo        = a_periodo
    and no_endoso        = "00000" 	

	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	foreach 
	 select suma_asegurada,
	        no_unidad
	   into _suma_asegurada,
	        _no_unidad
	   from endeduni
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso

		 Select r.porc_partic_suma
		   Into _porc_partic_suma
		   From emifacon r, reacomae c
		  Where r.no_poliza     = _no_poliza
		    And r.no_endoso     = _no_endoso
			and r.no_unidad     = _no_unidad
			and r.cod_contrato  = c.cod_contrato
			and c.tipo_contrato = 1;

		if _porc_partic_suma is null then
			let _porc_partic_suma = 0.00;
		end if

		return _no_documento,
		       _nombre_subramo,
			   _nombre_cliente,
			   _vigencia_inic,
			   _vigencia_final,
			   _suma_asegurada,
			   _porc_partic_suma,
			   null,
			   null,
			   _nombre_compania
			   with resume;

  		Foreach
		 Select r.cod_contrato,
				r.cod_cober_reas,
				r.orden,
				r.porc_partic_suma,
				c.tipo_contrato,
				c.nombre
		   Into _cod_contrato,
				_cod_cober_reas,
				_orden,
				_porc_partic_suma,
				_tipo_contrato,
				_nombre_cont
		   From emifacon r, reacomae c
		  Where r.no_poliza       = _no_poliza
		    And r.no_endoso       = _no_endoso
			and r.no_unidad       = _no_unidad
			and r.cod_contrato    = c.cod_contrato
			and c.tipo_contrato   <> 1

			If _tipo_contrato = 3 Then	--facultativo

				Foreach
				 Select cod_coasegur,
				        porc_partic_reas
				   Into _cod_coasegur,
				        _porc_partic
				   From emifafac
				  Where no_poliza      = _no_poliza
				    And no_endoso      = _no_endoso
					And no_unidad      = _no_unidad
					And cod_cober_reas = _cod_cober_reas
					And orden		   = _orden

					select nombre
					  into _nombre_reas
					  from emicoase
					 where cod_coasegur = _cod_coasegur;

					let _porc_partic = _porc_partic *_porc_partic_suma / 100;

					return null,
						   null,
						   null,
						   null,
						   null,
						   null,
						   null,
						   _porc_partic,
						   _nombre_reas,
						   _nombre_compania
						   with resume;

				End Foreach

			Else

			   FOREACH
					select cod_coasegur,
						   porc_cont_partic	
					  into _cod_coasegur,
						   _porc_partic
					  from reacoase
					 where cod_contrato   = _cod_contrato
					   and cod_cober_reas = _cod_cober_reas

					select nombre
					  into _nombre_cont
					  from emicoase
					 where cod_coasegur = _cod_coasegur;

					let _porc_partic = _porc_partic *_porc_partic_suma / 100;

				return null,
					   null,
					   null,
					   null,
					   null,
					   null,
					   null,
					   _porc_partic,
					   _nombre_cont ,
					   _nombre_compania
					   with resume;

			   END FOREACH

--				let _nombre_cont = _cod_contrato || " " || _nombre_cont;

			End If

		End Foreach
		
	end foreach
	
end foreach

end procedure









