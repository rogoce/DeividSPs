-- Insertando los valores de cambios de productos de las cartas de Salud en emicartasal2.
-- Creado    : 15/07/2010 - Autor: Henry Giron.
-- Modificado: 15/07/2010 - Autor: Henry Giron.
-- SIS v.2.0 -  - DEIVID, S.A.	  copia del sp_pro497.

drop procedure sp_pro573;
create procedure sp_pro573(
    a_no_poliza	char(10))
returning dec(16,2);

define _nombre            	varchar(100);
define _nombre_ramo			char(100);
define _nombre_plan			char(100);
define _nombre_subramo		char(100);
define _producto_nom     	char(50);
define _cod_asegurado		char(10);
define _cod_depend       	char(10);
define _no_poliza			char(10);
define _periodo_ant   	    char(7);
define _cod_producto_new	char(5);
define _cod_producto_ant    char(5);
define _cod_producto		char(5);
define _no_unidad       	char(5);
define _cod_grupo			char(5);
define _cod_formapag		char(3);
define _cod_perpago			char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _anio_aniv			char(4);
define _mes_aniv			char(2);
define _dia_aniv			char(2);
define _prima_plan_aseg		dec(16,2);
define _prima_asegurado 	dec(16,2);
define _prima_plan_dep		dec(16,2);
define _deducible_int		dec(16,2);
define _prima_bruta         dec(16,2);
define _prima_plan 			dec(16,2);
define _deducible			dec(16,2);
define _prima_ant       	dec(16,2);
define _co_pago  			dec(16,2);
define _porc_descuento      dec(5,2);
define _porc_impuesto       dec(5,2);
define _porc_recargo        dec(5,2);
define _por_recargo			dec(5,2);
define _fecha_aniversario	date;
define _fecha_periodo   	date;
define _fecha_actual        date;
define _desde				date;
define _error               smallint; 
define _edad            	smallint;
define _deducible_din		money(16,2);
define a_nom_cliente        varchar(100);
define a_periodo            char(7);
define a_fecha_aniv, _vigencia_inic date;
define _cnt_ducruet         smallint;
define _tipo_cambio         smallint;
define _no_documento        char(20);
define _periodo             char(7);
define _cod_prod_sav        char(5);

set isolation to dirty read;


	select cod_ramo,
		   cod_subramo,
		   cod_perpago,
		   cod_formapag,
		   cod_grupo,
		   prima_bruta,
		   periodo,
		   vigencia_inic,
		   no_documento
	  into _cod_ramo,
		   _cod_subramo,
		   _cod_perpago,
		   _cod_formapag,
		   _cod_grupo,
		   _prima_bruta,
		   _periodo_ant,
		   _vigencia_inic,
		   _no_documento
	  from emipomae
	 where no_poliza = a_no_poliza;
	 
	 select cod_producto,
	        fecha_aniv,
			periodo,
			cod_prod_sav
	   into _cod_producto,
	        a_fecha_aniv,
			_periodo,
			_cod_prod_sav
	   from emicartasal2
	  where no_documento = _no_documento;
	  
	-- Opcion de coberturas Asistencia de Viaje para julio y agosto 2018 Panamá Plus y Global
	if _periodo >= '2018-07' and _periodo <= '2018-08' and _cod_subramo in ('007','009') then
		let _cod_producto = _cod_prod_sav;
	end if
	
	--let _cod_producto = '03153';
	
	foreach
		select cod_asegurado,
			   no_unidad 
		  into _cod_asegurado,
			   _no_unidad
		  from emipouni
		 where no_poliza = a_no_poliza
		   and activo = 1

		select nombre, fecha_aniversario
		  into a_nom_cliente, _fecha_aniversario
		  from cliclien
		 where cod_cliente = _cod_asegurado;

		let _edad = sp_sis78(_fecha_aniversario, a_fecha_aniv);
			 
		select prima
		  into _prima_plan
		  from prdtaeda
		 where cod_producto	= _cod_producto
		   and edad_desde	<= _edad
		   and edad_hasta	>= _edad;
		   
		 if _prima_plan is null then
			let _prima_plan = 0;
		 end if
		  
		let _porc_recargo = 0.00;

		foreach
			select porc_recargo
			  into _porc_recargo
			  from emiunire
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad
			let _prima_plan = _prima_plan + _prima_plan * _porc_recargo / 100;
		end foreach

		let _prima_plan_aseg = _prima_plan;
		let _prima_plan = 0;
		let _prima_plan_dep = 0;

		foreach
			select cod_cliente
			  into _cod_depend
			  from emidepen
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad
			   and activo = 1

			select nombre, fecha_aniversario
			  into _nombre, _fecha_aniversario
			  from cliclien
			 where cod_cliente = _cod_depend;

			let _edad = sp_sis78(_fecha_aniversario, a_fecha_aniv);
			 
			select prima
			  into _prima_plan
			  from prdtaeda
			 where cod_producto = _cod_producto
			   and edad_desde   <= _edad
			   and edad_hasta   >= _edad;

			 if _prima_plan is null then
				let _prima_plan = 0;
			 end if
			   
		    let _porc_recargo = 0.00;
			   		
			select sum(por_recargo)
			  into _por_recargo
			  from emiderec
			 where no_poliza 	= a_no_poliza
			   and no_unidad	= _no_unidad
			   and cod_cliente	= _cod_depend;

			if _por_recargo is null then 
				let _por_recargo = 0.00;
			end if

			let _prima_plan = _prima_plan * (_por_recargo / 100) + _prima_plan;
			let _prima_plan_dep = _prima_plan_dep + _prima_plan;

		end foreach

		let _prima_plan = _prima_plan_aseg + _prima_plan_dep;

	end foreach

	let _deducible     = 0;
	let _deducible_int = 0;
	let _co_pago       = 0;
	let _porc_impuesto = 0;

	  -- impuesto	
	select sum(factor_impuesto)
	  into _porc_impuesto
	  from emipolim p, prdimpue i
	 where p.cod_impuesto = i.cod_impuesto
	   and p.no_poliza    = a_no_poliza;

	if _porc_impuesto is null then
		let _porc_impuesto = 0;
	end if

--	let _prima_plan = _prima_plan * (_porc_impuesto / 100) + _prima_plan;
--	let _prima_ant = _prima_ant * (_porc_impuesto / 100) + _prima_ant; 


return _prima_plan;
end procedure;



