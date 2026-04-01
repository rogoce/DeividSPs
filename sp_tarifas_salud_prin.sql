--Actaulizaciones para los recargos de salud
--30/07/2024
--Este Procedimiento se ejecuta cuando cierran produccion.
DROP procedure sp_tarifas_salud_prin;
CREATE procedure sp_tarifas_salud_prin(a_periodo char(7))
RETURNING smallint;

DEFINE _no_poliza 	CHAR(10);
DEFINE _no_documento        CHAR(20);
define _aumento dec(16,2);
define _no_unidad       char(5);
define _cantidad,_valor 		integer;
define _asegurado			varchar(50);
define _dependiente		varchar(50);
define _recargo_uni		varchar(50);
define _recargo_dep		varchar(50);
define _periodo_pago		char(20);
define _cod_dependiente		char(10);
define _cod_asegurado		char(10);
define _fecha_aniv_dep	date;
define _fecha_aniv_uni	date;
define _vigencia_inic		date;
define _fecha_hasta		date;
define _vigencia_final		date;
define _prima_neta_tot	dec(16,2);
define _porc_recarg_uni	dec(16,2);
define _porc_recarg_dep	dec(16,2);
define _cod_recargo		char(3);
define _cod_perpago		char(3);
define _meses,_opcion			smallint;
define _prima_dependiente	dec(16,2);
define _prima_neta_pol	dec(16,2);
define _cod_producto		char(5);
define _prima_desde		dec(16,2);
define _prima_hasta		dec(16,2);
define _prima_desde_dep	dec(16,2);
define _prima_hasta_dep	dec(16,2);
define _nom_corredor		varchar(150);
define _nom_zona			varchar(150);

--set debug file to "sp_tarifas_salud_prin.trc";
--trace on;

let _valor = 0;
if a_periodo > '2026-07' then	--Solo se debe hacer hasta julio 2026. AM.
	return 0;
end if

let _valor = sp_tarifas_salud_n2(a_periodo);-- Crea tabla tmp_tar_salud_n con los registros de asegurados y dependientes que se deben recargar

let _aumento = 31.5;

foreach
	select no_documento,
	       opcion
      into _no_documento,
	       _opcion
      from tmp_tar_salud_n
	 group by no_documento,opcion
     order by opcion 
  
	let _no_poliza = sp_sis21(_no_documento);
	let _cod_dependiente = null;
	foreach
		select no_unidad,
		       cod_asegurado,
			   cod_dependiente
		  into _no_unidad,
			   _cod_asegurado,
			   _cod_dependiente
		  from tmp_tar_salud_n
         where no_documento = _no_documento
		   and opcion       = _opcion

		--RECORRER LOS ASEGURADOS
		select count(*)
		  into _cantidad
		  from emiunire
		 where no_poliza   = _no_poliza
		   and no_unidad   = _no_unidad
		   and cod_recargo = '003';

		if _cantidad is null then
			let _cantidad = 0;
		end if
		
		if _cantidad = 0 and _opcion = 3 then	--Opcion 3, primer aumento. De no existir en la tabla se crea, de lo contrario ya tiene el 31.5
			insert into emiunire(no_poliza,no_unidad,cod_recargo,porc_recargo)
			values(_no_poliza,_no_unidad,'003',_aumento);
		end if
		if _cod_dependiente is null And _opcion in(1,4) then	--Opcion 1, aumenta de 31.5 a 63, que corresponde al segundo aumento
			update emiunire
			   set porc_recargo = porc_recargo + _aumento
			 where no_poliza   = _no_poliza
			   and no_unidad   = _no_unidad
			   and cod_recargo = '003';
		end if

		--RECORRER LOS DEPENDIENTES
		if _cod_dependiente is not null then
			select count(*)
			  into _cantidad
			  from emiderec
			 where no_poliza   = _no_poliza
			   and no_unidad   = _no_unidad
			   and cod_cliente = _cod_dependiente
			   and cod_recargo = '003';

			if _cantidad is null then
				let _cantidad = 0;
			end if

			if _cantidad = 0 and _opcion = 3 then	--Opcion 3, primer aumento. De no existir en la tabla se crea, de lo contrario ya tiene el 31.5
				insert into emiderec(no_poliza,no_unidad,cod_cliente,cod_recargo,por_recargo)
				values(_no_poliza,_no_unidad,_cod_dependiente,'003',_aumento);
			end if
			
			if _opcion in(1,4) then	--Opcion 1, aumenta de 31.5 a 63, que corresponde al segundo aumento
				update emiderec
				   set por_recargo = por_recargo + _aumento
				 where no_poliza    = _no_poliza
				   and no_unidad    = _no_unidad
				   and cod_cliente  = _cod_dependiente
				   and cod_recargo  = '003';
			end if
		end if
	end foreach
end foreach
drop table tmp_tar_salud_n;
Return _valor;
END PROCEDURE

