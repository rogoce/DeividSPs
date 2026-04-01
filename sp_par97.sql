
drop procedure sp_par97;

create procedure sp_par97()
returning char(5),
          char(15),
          char(3),
          char(20),
          smallint;

define _cod_contrato	char(5);
define _cod_cober_reas	char(3);
define _cantidad		smallint;

define _nomb_contrato	char(15);
define _nomb_cober		char(20);
define _tipo_contrato	smallint;
define _serie			smallint;

foreach
 select cod_contrato,
        cod_cober_reas
   into _cod_contrato,
        _cod_cober_reas
   from emifacon
  where suma_asegurada <> 0
    and prima <> 0
  group by 1, 2
  order by 1 desc, 2
  
	select count(*)
	  into _cantidad
	  from reacocob
	 where cod_contrato   = _cod_contrato
	   and cod_cober_reas = _cod_cober_reas;

	if _cantidad = 0 then

		select nombre,
		       tipo_contrato,
			   serie
		  into _nomb_contrato,
		       _tipo_contrato,
			   _serie
		  from reacomae
		 where cod_contrato = _cod_contrato;

--		if _tipo_contrato = 1 or
--		   _tipo_contrato = 3 then

			insert into reacocob(
			cod_contrato,
			cod_cober_reas,
			porc_comis_con,
			porc_comis_util,
			limite_maximo,
			verificar_limite,
			porc_impuesto,
			porc_comision,
			cuenta,
			tiene_comision
			)
			values(
			_cod_contrato,
			_cod_cober_reas,
			0.00,
			0.00,
			0.00,
			0,
			0.00,
			0.00,
			null,
			0
			);

--		end if


		select count(*)
		  into _cantidad
		  from reacocob
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		if _cantidad = 0 then

			select nombre
			  into _nomb_cober
			  from reacobre
			 where cod_cober_reas = _cod_cober_reas;

			return _cod_contrato, _nomb_contrato, _cod_cober_reas, _nomb_cober, _serie with resume;

		end if

	end if

end foreach


end procedure
