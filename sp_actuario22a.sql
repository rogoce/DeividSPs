drop procedure sp_actuario22a;
-- copia de sp_actuario
create procedure "informix".sp_actuario22a(a_no_factura char(10))
returning	integer,
			varchar(100);

BEGIN

define _error_desc			varchar(100);
define _no_documento		char(21);
define _no_factura			char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_cobertura		char(5);
define _cod_producto		char(5);
define _cod_agente			char(5);
define _no_unidad			char(5);
define _cod_grupo			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_tipoprod		char(3);
define _cod_sucursal        char(3);
define _cod_ramo			char(3);
define _diferencia_prima	dec(16,2);
define _prima_neta_cob		dec(16,2);
define _prima_neta_uni		dec(16,2);
define _prima_neta_end		dec(16,2);
define _prima_anual			dec(16,2);
define _descuento			dec(16,2);
define _recargo				dec(16,2);
define _cnt_coberturas		smallint;
define _cnt_unidades		smallint;
define _cnt_existe			smallint;
define _num_ano				smallint;
define _error_isam			integer;
define _error				integer;
define _date_added			date;

on exception set _error,_error_isam,_error_desc
	return _error,_error_desc;
end exception

--set debug file to "sp_actuario22a.trc";
--trace on;

set isolation to dirty read;

foreach
	select no_factura,
		   no_poliza,
		   no_endoso
	  into _no_factura,
		   _no_poliza,
		   _no_endoso
	  from endedmae e
	 where e.no_factura = a_no_factura
	 --order by 1,5
	
	{foreach
		select no_unidad,
			   prima_neta
		  into _no_unidad,
			   _prima_neta
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
	
		foreach
			select cod_cobertura
			  into _cod_cobertura
			  from emipocob
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			exit foreach;
		end foreach
	{select count(*)
	  into _cnt_unidades
	  from endeduni
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
	
	{if _cnt_unidades > 2 then
		continue foreach;
	end if
	
	select count(*)
	  into _cnt_coberturas
	  from endedcob
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
	   --and prima_neta <> 0;
	
	{if _cnt_coberturas > 1 then
		continue foreach;
	end if
	
	{update endedcob
	   set prima_neta = _prima_neta_end
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso
	   and prima_neta <> 0;}
	
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	--if _cnt_coberturas <> _cnt_unidades then		
		if _cod_ramo = '018' then
			foreach
				select no_unidad,
					   cod_producto,
					   prima,
					   descuento,
					   recargo,
					   prima_neta,
					   vigencia_inic
				  into _no_unidad,
					   _cod_producto,
					   _prima_anual,
					   _descuento,
					   _recargo,
					   _prima_neta_uni,
					   _date_added
				  from endeduni
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				
				select count(*)
				  into _cnt_existe
				  from endedcob
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				   and no_unidad = _no_unidad;
				
				let _prima_neta_cob = 0.00;
				
				select prima_neta
				  into _prima_neta_cob
				  from endedcob
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				   and no_unidad = _no_unidad;
				
				if _prima_neta_cob is null then
					let _prima_neta_cob = 0.00;
				end if

				if _prima_neta_uni <> _prima_neta_cob then
					if _cnt_existe is null or _cnt_existe = 0 then
						foreach
							select cod_cobertura
							  into _cod_cobertura
							  from prdcobpd
							 where cod_producto = _cod_producto
							exit foreach;
						end foreach
						
						insert into endedcob(
								no_poliza,
								no_endoso,
								no_unidad,
								cod_cobertura,
								orden,
								tarifa,
								deducible,
								limite_1,
								limite_2,
								prima_anual,
								prima,
								descuento,
								recargo,
								prima_neta,
								date_added,
								date_changed,
								desc_limite1,
								desc_limite2,
								factor_vigencia)
						values(	_no_poliza,
								_no_endoso,
								_no_unidad,
								_cod_cobertura,
								1,
								0,
								0.00,
								0,
								0,
								_prima_anual,
								_prima_anual,
								_descuento,
								_recargo,
								_prima_neta_uni,
								_date_added,
								_date_added,
								NULL,
								NULL,
								1
								);
					end if
				end if
			end foreach
		end if			
	--end if
	
	return	0,'Actualizacion Exitosa';
end foreach
end 
end procedure 