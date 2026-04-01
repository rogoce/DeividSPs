-- Procedure que genera la informacion solicitada por Maruquel
-- para el actuario de Multinacional

drop procedure sp_pro306;

create procedure sp_pro306(a_ano smallint)
returning char(10),
          char(10),
		  smallint,
		  char(50),
		  dec(16,2),
		  dec(16,2),
		  char(20),
		  char(50),
		  char(1),
		  date,
		  date,
		  date,
		  dec(16,2),
		  char(20),
		  char(50);
		  	
define _no_poliza		char(10);
define _no_unidad		char(5);
define _cod_asegurado	char(10);
define _cod_reclamante	char(10);
define _cod_parentesco	char(3);
define _nombre_paren	char(50);
define _suma_asegurada	dec(16,2);
define _prima			dec(16,2);
define _cod_producto	char(5);
define _nombre_prod		char(50);
define _deducible		dec(16,2);
define _no_documento	char(20);
define _sucursal_origen	char(3);
define _centro_costo	char(3);
define _fecha_emision	date;
define _vigencia_inic	date;
define _vigencia_final	date;
define _nombre_sucur	char(50);
define _fecha_naci		date;
define _sexo			char(1);
define _cantidad_uni	smallint;
define _tipo_poliza		char(20);
define _edad			smallint;

foreach
 select no_poliza
   into	_no_poliza
   from endedmae
  where cod_endomov       in ("011", "014")
    and actualizado       = 1
	and no_documento[1,2] = "18"
	and (year(vigencia_inic)  = a_ano or
     	 year(vigencia_final) = a_ano)
  group by no_poliza
     
	-- Datos de la Poliza		

	 select no_documento,
	        sucursal_origen,
		    fecha_suscripcion,
		    vigencia_inic,
		    vigencia_final
	   into _no_documento,
	        _sucursal_origen,
		    _fecha_emision,
		    _vigencia_inic,
		    _vigencia_final
	   from emipomae
	  where no_poliza = _no_poliza;

	select centro_costo
	  into _centro_costo
	  from insagen
	 where codigo_agencia = _sucursal_origen;

	select descripcion
	  into _nombre_sucur
	  from insagen
	 where codigo_agencia = _centro_costo;

	select count(*)
	  into _cantidad_uni
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cantidad_uni > 1 then
		let _tipo_poliza = "COLECTIVA";
	else
		let _tipo_poliza = "INDIVIDUAL";
	end if		

   foreach	
	select cod_asegurado,
	       suma_asegurada,
		   cod_producto,
		   prima,
		   no_unidad
	  into _cod_asegurado,
	       _suma_asegurada,
		   _cod_producto,
		   _prima,
		   _no_unidad
	  from emipouni
	 where no_poliza = _no_poliza

		let _nombre_paren = "TITULAR";

		select deducible_local,
		       nombre
		  into _deducible,
		       _nombre_prod
		  from prdprod
		 where cod_producto = _cod_producto;

		select fecha_aniversario,
		       sexo
		  into _fecha_naci,
		       _sexo
		  from cliclien
		 where cod_cliente = _cod_asegurado;

		let _edad = sp_sis78(_fecha_naci, _fecha_emision);

{
		if _edad < 0 or
		   _edad is null then
			let _fecha_documento = _fecha_reclamo;
			let _edad = sp_sis78(_fecha_naci, _fecha_documento);
		end if
}

		return _cod_asegurado,
		       _cod_asegurado,
			   _edad,
			   _nombre_paren,
			   _suma_asegurada,
			   _deducible,
			   _no_documento,
			   _nombre_sucur,
			   _sexo,
			   _fecha_emision,
			   _vigencia_inic,
			   _vigencia_final,
			   _prima,
			   _tipo_poliza,
			   _nombre_prod
			   with resume;

	   foreach
		select cod_parentesco,
		       cod_cliente
		  into _cod_parentesco,
		       _cod_reclamante
		  from emidepen
		 where no_poliza   = _no_poliza
		   and no_unidad   = _no_unidad

			select nombre
			  into _nombre_paren
			  from emiparen
			 where cod_parentesco = _cod_parentesco;

			select fecha_aniversario,
			       sexo
			  into _fecha_naci,
			       _sexo
			  from cliclien
			 where cod_cliente = _cod_reclamante;

			let _edad = sp_sis78(_fecha_naci, _fecha_emision);

			return _cod_asegurado,
			       _cod_reclamante,
				   _edad,
				   _nombre_paren,
				   _suma_asegurada,
				   _deducible,
				   _no_documento,
				   _nombre_sucur,
				   _sexo,
				   _fecha_emision,
				   _vigencia_inic,
				   _vigencia_final,
				   _prima,
				   _tipo_poliza,
				   _nombre_prod
				   with resume;

		end foreach
		
   end foreach

end foreach

end procedure