-- Cant polizas vigentes por marca / modelo, DRN 11780
--

DROP procedure sp_marca_modelo_temis1;
CREATE procedure sp_marca_modelo_temis1()
RETURNING char(10),char(5);

define _no_poliza	 	CHAR(10);
define _no_documento char(20);
define _cod_marca,_cod_modelo  char(5);
define v_filtros        varchar(255);
define _no_unidad       char(5);
define _estatus_p,_cambio_pol       smallint;
define _no_motor        char(30);
define _cnt,_valor,_cant_pol,_cant_pol_suma integer;

--CALL sp_pro03("001","001",a_fecha,"002,020,023;") RETURNING v_filtros;

create temp table tmp_pol_mar_mod(
no_documento     char(20),
cod_modelo      char(5),
primary key(no_documento, cod_modelo)) with no log;
---create index idx1_tmp_pol_mar_mod on tmp_pol_mar_mod(no_documento,cod_modelo);

--	 where cod_marca in('00062','01603') se uso para pruebas

foreach
	select cod_modelo
	  into _cod_modelo
	  from deivid_tmp:marca_modelo
	 order by cod_modelo
	 
	foreach
		select no_motor
		  into _no_motor
		  from emivehic
		 where cod_modelo = _cod_modelo
		 
		foreach 
			select distinct no_documento
			  into _no_documento
			  from emipomae
			 where no_poliza in(
			      select distinct no_poliza
			        from emiauto
			       where no_motor in(
			           select no_motor
			             from emivehic
			            where cod_modelo = _cod_modelo
						  and no_motor   = _no_motor))
			   and actualizado = 1
			   
			let _no_poliza = sp_sis21(_no_documento);
			
			select estatus_poliza
			  into _estatus_p
			  from emipomae
			 where no_poliza = _no_poliza;
			
			let _valor = 0;
		    if _estatus_p = 1 then	--Vigente
				let _valor = 1;
			end if
			
			select count(*)
			  into _cnt
			  from tmp_pol_mar_mod
			 where no_documento = _no_documento
               and cod_modelo = _cod_modelo;

			if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt = 0 then
				insert into tmp_pol_mar_mod
				values(_no_documento,_cod_modelo);
				
				update deivid_tmp:marca_modelo
				   set cant_pol = cant_pol + 1,
					   cant_pol_vig = cant_pol_vig + _valor
				 where cod_modelo = _cod_modelo;
			end if
			 
		end foreach

	end foreach
	
end foreach
drop table tmp_pol_mar_mod;
return '','Fin';
END PROCEDURE;
