-- Insertando los valores de cambios de productos de las cartas de Salud en emicartasal5.
-- Creado    : 26/01/2010 - Autor: Amado Perez.
-- 
-- SIS v.2.0 -  - DEIVID, S.A.	  copia del sp_pro497.

drop procedure sp_pro1107;
create procedure sp_pro1107(
    a_periodo		char(7),
    a_grupo		    char(5) default '%',
    a_no_documento	char(20) default '%',
    a_usuario		char(8) default null)
returning smallint,char(100);

define _cod_asegurado		char(10);
define _cod_depend       	char(10);
define _no_poliza			char(10);
define _cod_ramo            char(3); 
define _cod_producto_new	char(5);
define _cod_producto_ant    char(5);
define _cod_producto		char(5);
define _no_unidad       	char(5);
define _cod_grupo			char(5);
define _prima_plan_aseg		dec(16,2);
define _prima_asegurado 	dec(16,2);
define _prima_plan_dep		dec(16,2);
define _prima_bruta         dec(16,2);
define _prima_plan 			dec(16,2);
define _prima_ant       	dec(16,2);
define _porc_descuento      dec(5,2);
define _porc_impuesto       dec(5,2);
define _porc_recargo        dec(5,2);
define _por_recargo			dec(5,2);
define _fecha_aniversario	date;
define _fecha_desde   	    date;
define _fecha_hasta   	    date;
define _fecha_actual        date;
define _desde				date;
define _error               smallint; 
define _edad            	smallint;
define _deducible_din		money(16,2);
define _vigencia_inic       date;
define _vigencia_final      date;
define _cnt                 smallint;
define _no_poliza_b         char(10);
define _cantidad            integer;
define _no_documento        char(20);
define _anos                smallint;  
define _cod_contratante     char(10);
define _anio_aniv			char(4);
define _mes_aniv			char(2);
define _dia_aniv			char(2);
define _fecha_aniv 			date;
define _cod_subramo         char(3);
define _periodo_ctrl        char(7);
define _fecha_ctrl          date;

let _cnt = 0;

--if a_no_documento = '1817-00179-01' then
--  set debug file to "sp_pro466.trc";
-- trace on;
--end if

set isolation to dirty read;

select emi_periodo
  into _periodo_ctrl
  from parparam;
 
let _fecha_ctrl   = mdy(_periodo_ctrl[6,7], 1, _periodo_ctrl[1,4]); 

let _fecha_actual  = sp_sis26() ;
let _fecha_desde   = mdy(a_periodo[6,7], 1, a_periodo[1,4]);
let _fecha_hasta   = (_fecha_desde + 1 units month) - 1 units day;


if _fecha_desde <= _fecha_ctrl then
	return 1, 'No puede introducir un periodo menor o igual al actual';
end if	


let _prima_bruta = 0;


-- Ramo de Salud

select cod_ramo
  into _cod_ramo
  from prdramo
 where ramo_sis = 5;


begin
 
on exception set _error 
 		return _error, a_no_documento;         
end exception 
 
 if a_no_documento <> '%' then
	call sp_sis21(a_no_documento) returning _no_poliza_b;
 else
	let _no_poliza_b = '%';
 end if
 
 if _no_poliza_b is null then
	let _no_poliza_b = '%';
 end if
 
 foreach
	select no_documento,
	       no_poliza,
		   cod_grupo,
		   cod_pagador,
		   prima_bruta,
		   vigencia_inic,
		   vigencia_final,
		   cod_subramo
	  into _no_documento,
	       _no_poliza,
		   _cod_grupo,
		   _cod_contratante,
		   _prima_bruta,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_subramo
	  from emipomae
	 where cod_ramo = _cod_ramo
	   and month(vigencia_inic) = month(_fecha_desde)
	   and estatus_poliza = 1
	   and actualizado    = 1
	   and no_poliza like _no_poliza_b
	   and cod_grupo like a_grupo
	
 	 
    let _cantidad = 0;
	
	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = _no_poliza 
	   and activo = 1;	   --> Le agregue esta condicion Amado 2/8/2011 
	   
	if _cantidad is null then
		let _cantidad = 0;
	end if	

	if _cantidad > 1 or _cantidad = 0 then
		continue foreach;
	end if
	
	if _no_documento in('1822-00346-01','1822-00302-01','1822-00306-01','1822-00357-01','1822-00462-01') then --Caso #9261 no incluir en la tabla emicartasal5 estas pólizas
		continue foreach;
	end if
			
	select cod_producto,
		   prima_asegurado,
		   cod_asegurado,
           no_unidad		   
	  into _cod_producto,
		   _prima_asegurado,
		   _cod_asegurado,
		   _no_unidad
	  from emipouni
	 where no_poliza = _no_poliza
	   and activo = 1;

	let _cod_producto_ant = _cod_producto;
	let _prima_ant = _prima_asegurado;
    let _cod_producto_new = null;	
	
	select producto_nuevo
	  into _cod_producto_new
	  from prdnewpro
	 where cod_producto = _cod_producto
	   and activo = 1;
				
	  -- tarifas nuevos productos
	let _prima_plan = 0;
	let _prima_plan_aseg = 0;
	let _prima_plan_dep = 0;

	if _cod_producto_new is not null then
		let _cod_producto = _cod_producto_new;
	else
		continue foreach;
	end if
	
	if month(_vigencia_inic) < month(_fecha_desde) then
		let _anio_aniv =   a_periodo[1,4];
		let _mes_aniv  =   month(_vigencia_inic);
		let _dia_aniv  =   day(_vigencia_inic);
		let _fecha_aniv = mdy(_mes_aniv,_dia_aniv,_anio_aniv);
		let _fecha_aniv = _fecha_aniv + 1 units year;
	else
		let _anio_aniv =   a_periodo[1,4];
		let _mes_aniv  =   month(_vigencia_inic);
		let _dia_aniv  =   day(_vigencia_inic);
		let _fecha_aniv = mdy(_mes_aniv,_dia_aniv,_anio_aniv);
	end if	

	foreach
		select cod_asegurado,
			   no_unidad 
		  into _cod_asegurado,
			   _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza
		   and activo = 1

		select fecha_aniversario
		  into _fecha_aniversario
		  from cliclien
		 where cod_cliente = _cod_asegurado;

		let _edad = sp_sis78(_fecha_aniversario, _fecha_aniv);
			 
		select prima
		  into _prima_plan
		  from prdtaeda
		 where cod_producto	= _cod_producto
		   and edad_desde	<= _edad
		   and edad_hasta	>= _edad;
		  
		let _porc_recargo = 0.00;

		foreach
			select porc_recargo
			  into _porc_recargo
			  from emiunire
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			let _prima_plan = _prima_plan + _prima_plan * _porc_recargo / 100;
			let _prima_ant  = _prima_ant  + _prima_ant  * _porc_recargo / 100; 
		end foreach

		let _prima_plan_aseg = _prima_plan;
		let _prima_plan = 0;
		let _prima_plan_dep = 0;

        if _cod_subramo <> '012' then
			foreach
				select cod_cliente
				  into _cod_depend
				  from emidepen
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				   and activo = 1

				select fecha_aniversario
				  into _fecha_aniversario
				  from cliclien
				 where cod_cliente = _cod_depend;

				let _edad = sp_sis78(_fecha_aniversario, _fecha_aniv);
				 
				select prima
				  into _prima_plan
				  from prdtaeda
				 where cod_producto = _cod_producto
				   and edad_desde   <= _edad
				   and edad_hasta   >= _edad;
				   
				let _porc_recargo = 0.00;
						
				select sum(por_recargo)
				  into _por_recargo
				  from emiderec
				 where no_poliza 	= _no_poliza
				   and no_unidad	= _no_unidad
				   and cod_cliente	= _cod_depend;

				if _por_recargo is null then 
					let _por_recargo = 0.00;
				end if

				let _prima_plan = _prima_plan * (_por_recargo / 100) + _prima_plan;
				let _prima_plan_dep = _prima_plan_dep + _prima_plan;

			end foreach
        end if
		let _prima_plan = _prima_plan_aseg + _prima_plan_dep;

	end foreach

	let _porc_impuesto = 0;

	  -- impuesto	
	select sum(factor_impuesto)
	  into _porc_impuesto
	  from emipolim p, prdimpue i
	 where p.cod_impuesto = i.cod_impuesto
	   and p.no_poliza    = _no_poliza;

	if _porc_impuesto is null then
		let _porc_impuesto = 0;
	end if

	let _prima_plan = _prima_plan * (_porc_impuesto / 100) + _prima_plan;
	let _prima_ant = _prima_ant * (_porc_impuesto / 100) + _prima_ant; 


    select count(*)
	  into _cnt
	  from emicartasal5
	 where no_documento = _no_documento;
	 
	 if _cnt > 0 then
 		update emicartasal5
 		   set  cod_contratante = _cod_contratante,
		        cod_asegurado   = _cod_asegurado,
				cod_grupo       = _cod_grupo,
				producto_act    = _cod_producto_ant,
				producto_nvo    = _cod_producto,
				periodo         = a_periodo,
				fecha_aniv      = _fecha_aniv,
				prima_act       = _prima_ant,
				prima_nvo       = _prima_plan,
				enviado_a      = 0,
				impreso        = 0,
		        user_added     = a_usuario,
				date_added     = current
 		 where  no_documento   = _no_documento; 
    else	
		insert into emicartasal5(
				no_documento,
				cod_contratante,
				cod_asegurado,
				cod_grupo,
				producto_act,
				producto_nvo,
				periodo,
				fecha_aniv,
				prima_act,
				prima_nvo,
				impreso,
				enviado_a,
				user_added,
				date_added)
		values(
				_no_documento,
				_cod_contratante,
				_cod_asegurado,
				_cod_grupo,
				_cod_producto_ant,
				_cod_producto,
				a_periodo,
				_fecha_aniv,  
				_prima_ant,
				_prima_plan,
				0,           
				0,    
				a_usuario,
				current);
     end if
end foreach
end
return 0, "actualizacion exitosa";
end procedure;



