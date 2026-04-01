-- Insertando los valores de en las primas de las cartas de Salud en emicartasal6.
-- Creado    : 09/07/2025 - Autor: Amado Perez.
-- Modificado: 09/07/2025 - Autor: Amado Perez.
-- SIS v.2.0 -  - DEIVID, S.A.	  

drop procedure sp_pro605;
create procedure sp_pro605(
    a_no_documento	char(20),
    a_prima_actual  dec(16,2),
    a_prima_nueva	dec(16,2),
	a_periodo 		char(7),
	a_usuario       char(8),
	a_opcion        smallint)
returning smallint,varchar(100);

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
--define a_periodo            char(7);
define a_fecha_aniv, _vigencia_inic date;
define _cnt_ducruet         smallint;
define _tipo_cambio         smallint;
define _siniestralidad      dec(16,2);
define _sinies              smallint;
define _ducruet             smallint;
define _prima_devengada     dec(16,2);
define _incurrido_bruto     dec(16,2);
define _fecha_proceso       datetime year to fraction (5);
define _nom_producto_ant    varchar(50);
define _producto_sav        char(5);
define _producto_cav        char(5);
define _cnt                 smallint;
define _cod_cob_viaje       char(5);
define _cod_contratante     char(10);

let _cnt = 0;

--if a_no_documento = '1817-00179-01' then
-- set debug file to "sp_pro605.trc";
-- trace on;
--end if

set isolation to dirty read;

let _fecha_actual  = sp_sis26() ;
let _fecha_periodo = mdy(a_periodo[6,7], 1, a_periodo[1,4]);

let _nombre_plan = "";
let _prima_bruta = 0;
let _tipo_cambio = 0;

--if a_fecha_aniv < _fecha_periodo then
{	let _anio_aniv =   a_periodo[1,4];
	let _mes_aniv  =   month(a_fecha_aniv);
	let _dia_aniv  =   day(a_fecha_aniv);
	let a_fecha_aniv = mdy(_mes_aniv,_dia_aniv,_anio_aniv);}
--	let a_fecha_aniv = a_fecha_aniv + 1 units year;
--end if 

begin
 
on exception set _error 
		return _error, a_no_documento;         
end exception 
 
 call sp_sis21(a_no_documento) returning _no_poliza;

If _no_poliza is not null then 
	select cod_pagador,
	       cod_grupo,
		   vigencia_inic
	  into _cod_contratante,
	       _cod_grupo,
		   _vigencia_inic
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	 if month(_vigencia_inic) <> month(_fecha_periodo) then
		return 1, trim(a_no_documento) || " " || "No cumple aniversario para el periodo " || a_periodo;
	 end if
		
	let _fecha_aniversario = mdy(a_periodo[6,7], day(_vigencia_inic), a_periodo[1,4]);
	
	foreach
		select cod_producto,
			   cod_asegurado 
		  into _cod_producto,
			   _cod_asegurado
		  from emipouni
		 where no_poliza = _no_poliza
		   and activo = 1
		exit foreach;
	end foreach

	let _cod_producto_ant = _cod_producto;
    let _cod_producto_new = _cod_producto;

    select count(*)
	  into _cnt
	  from emicartasal6
	 where no_documento = a_no_documento;
	 
	 if _cnt > 0 then
 		update emicartasal6
 		   set  cod_contratante = _cod_contratante,
 		        cod_asegurado   = _cod_asegurado,		
				cod_grupo      	= _cod_grupo,
				producto_act   	= _cod_producto_ant,
				producto_nvo    = _cod_producto_new,
				periodo  		= a_periodo,
				fecha_aniv     	= _fecha_aniversario,
				prima_act    	= a_prima_actual,
				prima_nvo   	= a_prima_nueva,
				user_changed 	= a_usuario,
				date_changed 	= current,
				impreso			= 0,
				enviado_a		= 0,
				enviado_email	= 0,
				opcion = a_opcion
 		 where  no_documento = a_no_documento; 
    else	
		insert into emicartasal6(
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
				date_added,
				enviado_email,
				opcion)
		values(
				a_no_documento,
				_cod_contratante,
				_cod_asegurado,  
				_cod_grupo, 
				_cod_producto_ant,
				_cod_producto_new,
				a_periodo,
				_fecha_aniversario,
				a_prima_actual,
				a_prima_nueva,
				0,
				0,
				a_usuario,
				current,
				0,
				a_opcion);
     end if
end if
end
return 0, "actualizacion exitosa";
end procedure;



