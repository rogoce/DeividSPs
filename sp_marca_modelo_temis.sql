-- Cant polizas vigentes por marca / modelo, DRN 11780
--

DROP procedure sp_marca_modelo_temis;
CREATE procedure sp_marca_modelo_temis(a_fecha date)
RETURNING char(10),char(5);

define _no_poliza	 	CHAR(10);
define _cod_marca,_cod_modelo  char(5);
define v_filtros        varchar(255);
define _no_unidad       char(5);
define _estatus_p,_cambio_pol       smallint;
define _no_motor        char(30);
define _cnt,_valor,_cant_pol,_cant_pol_suma integer;

--CALL sp_pro03("001","001",a_fecha,"002,020,023;") RETURNING v_filtros;

foreach
	select no_poliza
	  into _no_poliza
	  from emipoliza
	 where cod_ramo in('002','020','023')
	   and no_poliza in('0002814324','665061')
	 
	select estatus_poliza
      into _estatus_p
      from emipomae
     where no_poliza = _no_poliza;
	 
	let _cambio_pol = 1; 
	 
	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza

		select no_motor
		  into _no_motor
		  from emiauto
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;
		   
		select cod_marca,
		       cod_modelo
		  into _cod_marca,
		       _cod_modelo
		  from emivehic
         where no_motor = _no_motor;

		select count(*)
		  into _cnt
		  from deivid_tmp:marca_modelo
		 where cod_marca  = _cod_marca
		   and cod_modelo = _cod_modelo;
		
		let _valor = 0;
		
		if _cnt is null then
			let _cnt = 0;
		end if
		
		if _cnt > 0 then
		    if _estatus_p = 1 then	--Vigente
				let _valor = 1;
			else
				let _valor = 0;
			end if
			
			if _cambio_pol = 1 then --actualizar la marca
				update deivid_tmp:marca_modelo
				   set cant_pol = cant_pol + 1
				 where cod_marca  = _cod_marca
				   and cant_pol > 0;
				   
				let _cambio_pol = 0;   
			end if
			
			select sum(cant_pol)
			  into _cant_pol_suma
			  from deivid_tmp:marca_modelo
			 where cod_marca  = _cod_marca;
			   
			if _cant_pol_suma > 0 then
				let _cant_pol = 0;
			else
				let _cant_pol = 1;
			end if
			update deivid_tmp:marca_modelo
			   set cant_pol = cant_pol + _cant_pol,
			       cant_pol_vig = cant_pol_vig + _valor
			 where cod_marca  = _cod_marca
			   and cod_modelo = _cod_modelo;
			 
			return _no_poliza,_cod_modelo with resume; 
				   
		end if
	end foreach
end foreach
return '','Fin';
END PROCEDURE;
