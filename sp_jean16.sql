--Actaulizaciones para los recargos de salud
--30/07/2024

DROP procedure sp_jean16;
CREATE procedure sp_jean16()
RETURNING char(3),char(20),char(10),char(5),dec(16,2),smallint,smallint;

DEFINE _cod_contratante,_no_poliza,_no_pol,_no_endoso 	CHAR(10);
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
foreach
	select poliza,
	       codasegurado,
		   aumento
	  into _no_documento,
		   _cod_contratante,
		   _aumento
	  from deivid_tmp:salud_ren_rec
	 where vigenciainicial = '01/01/1900'
	  
	let _no_poliza = sp_sis21(_no_documento);
	let _aumento = 31.5;
	
	let _cnt = 0;
	foreach
		select no_unidad,
		       activo
		  into _no_unidad,
		       _activo
		  from emipouni
		 where no_poliza     = _no_poliza
           and cod_asegurado = _cod_contratante
		   
		select count(*)
          into _cantidad
          from emiunire
         where no_poliza   = _no_poliza
           and no_unidad   = _no_unidad
           and cod_recargo = '003';

		if _cantidad is null then
			let _cantidad = 0;
		end if
		if _cantidad = 0 then
			insert into emiunire(no_poliza,no_unidad,cod_recargo,porc_recargo)
			values(_no_poliza,_no_unidad,'003',_aumento);
		
			let _cnt = _cnt + 1;
			return 'Ase',_no_documento,_cod_contratante,_no_unidad,_aumento,_activo,_cnt with resume;
		end if	
		
	end foreach
	
end foreach	
	  
--RECORRER LOS DEPENDIENTES
foreach
	select poliza,
	       codasegurado,
		   aumento
	  into _no_documento,
		   _cod_contratante,
		   _aumento
	  from deivid_tmp:salud_ren_rec
	 where asegurado = 'DEP'
	  
	let _no_poliza = sp_sis21(_no_documento);
	let _aumento = 31.5;
	let _cnt = 0;
	
	foreach
		select no_unidad,
		       activo
		  into _no_unidad,
		       _activo
		  from emidepen
		 where no_poliza     = _no_poliza
           and cod_cliente   = _cod_contratante
		   
		select count(*)
          into _cantidad
          from emiderec
         where no_poliza   = _no_poliza
           and no_unidad   = _no_unidad
		   and cod_cliente = _cod_contratante
           and cod_recargo = '003';

		if _cantidad is null then
			let _cantidad = 0;
		end if

		if _cantidad = 0 then
		   
			insert into emiderec(no_poliza,no_unidad,cod_cliente,cod_recargo,por_recargo)
			values(_no_poliza,_no_unidad,_cod_contratante,'003',_aumento);
			let _cnt = _cnt + 1;
			return 'Dep',_no_documento,_cod_contratante,_no_unidad,_aumento,_activo,_cnt with resume;
		end if
	end foreach
	
end foreach
END PROCEDURE

