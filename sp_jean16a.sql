--Actaulizaciones para los recargos de salud
--30/07/2024

DROP procedure sp_jean16a;
CREATE procedure sp_jean16a(a_no_poliza char(10))
RETURNING smallint;

DEFINE _cod_contratante 	CHAR(10);
DEFINE _no_documento        CHAR(20);
define _aumento,_montoaumento,_primanueva dec(16,2);
define _no_unidad       char(5);
define _cnt,_activo,_act     smallint;
define _cantidad 		integer;
define _per,_periodo 		char(7);
define _vi,_vf,_vig_ini,_vig_fin		 date;


--set debug file to "sp_jean16.trc";
--trace on;

--RECORRER LOS ASEGURADOS
let _aumento = 31.5;

foreach
	select no_unidad
	  into _no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza
	   
	select count(*)
	  into _cantidad
	  from emiunire
	 where no_poliza   = a_no_poliza
	   and no_unidad   = _no_unidad
	   and cod_recargo = '003';

	if _cantidad is null then
		let _cantidad = 0;
	end if
	if _cantidad = 0 then
		insert into emiunire(no_poliza,no_unidad,cod_recargo,porc_recargo)
		values(a_no_poliza,_no_unidad,'003',_aumento);
	end if	
end foreach
	
	  
--RECORRER LOS DEPENDIENTES
foreach
	select no_unidad,
	       cod_cliente
	  into _no_unidad,
		   _cod_contratante
	  from emidepen
	 where no_poliza     = a_no_poliza
	   
	select count(*)
	  into _cantidad
	  from emiderec
	 where no_poliza   = a_no_poliza
	   and no_unidad   = _no_unidad
	   and cod_cliente = _cod_contratante
	   and cod_recargo = '003';

	if _cantidad is null then
		let _cantidad = 0;
	end if

	if _cantidad = 0 then
		insert into emiderec(no_poliza,no_unidad,cod_cliente,cod_recargo,por_recargo)
		values(a_no_poliza,_no_unidad,_cod_contratante,'003',_aumento);
	end if
end foreach
return 0;
END PROCEDURE

