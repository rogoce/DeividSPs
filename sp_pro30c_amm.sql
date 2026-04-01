-- Procedure que realiza el calculo de las tarifas nuevas de salud 
-- como el cambio de tarifa por el cambio de edad

-- Creado    : 23/08/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_pro30 - DEIVID, S.A.

drop procedure sp_pro30c_amm;
create procedure sp_pro30c_amm(a_no_poliza char(10))
returning smallint,
          char(50);

define _fecha_nac		date;
define _edad			smallint;
define _anos			smallint;
define _cod_cliente		char(10);
define _cod_producto	char(5);
define _producto_nuevo	char(5);
define _prima_total		dec(16,2);
define _prima_plan		dec(16,2);
define _prima_vida		dec(16,2);
define _cantidad		smallint;

define _porc_descuento  dec(5,2);
define _porc_recargo    dec(5,2);
define _porc_impuesto   dec(5,2);
define _porc_coas       dec(7,4);

define _vigencia_inic	date;
define _vigencia_final	date;
define _cod_tipoprod	char(3);

define _cod_perpago		char(3);
define _meses,_edad_desde,_edad_hasta	smallint;

define _no_unidad		char(5);
define _prima			dec(16,2);
define _descuento		dec(16,2);
define _recargo			dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _prima_bruta		dec(16,2);
define _prima_suscrita	dec(16,2);
define _prima_retenida	dec(16,2);
define _cambiar_tarifas	smallint;
define _no_documento	char(20);

define _error			smallint;
define _tipo_suscrip	smallint;
define _cod_subramo		char(3);

DEFINE _mes_contable    CHAR(2);
DEFINE _ano_contable    CHAR(4);
DEFINE _periodo 		CHAR(7);
define _tar_salud       smallint;
define _cod_depend      CHAR(10);
define _prima_plan_dep	dec(16,2);
define _prima_vida_dep	dec(16,2);
define _tarifa_dep	    dec(16,2);
define _tarifa_dep_tot 	dec(16,2);
DEFINE _fecha_aniversario 	DATE;
DEFINE _cod_grupo       CHAR(5);
DEFINE _fecha_a         date;
define _anno,_ano_salno integer;
define _cod_cober       char(5);
define _desc_limite1    varchar(50,0);
define _desc_limite2	varchar(50,0);
define _orden_n         smallint;
define _ded_n           varchar(50);
define _ded_nn          dec(16,2);
define v_fecha_r        date;
define _prima_nn        dec(16,2);
define _cnt             integer;
define _cod_parentesco  char(3);
define _tipo_pariente,_tipo_par_prod   smallint;

--set debug file to "sp_pro30c.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error
	return _error, "Error al Cambiar Tarifas...";
end exception

let _fecha_a  = current;
let _anno     = year(_fecha_a);
LET v_fecha_r = current;
let _cnt      = 0;

select no_documento
  into _no_documento
  from emipomae
 where no_poliza = a_no_poliza;
 
select ano
  into _ano_salno
  from prdsalno
 where no_documento = _no_documento;

select count(*)
  into _cantidad
  from prdsalno
 where no_documento = _no_documento
   and liberar      = 0;

if _cantidad >= 1 then
	return 0, "Actualizacion Exitosa...";
end if

select count(*)
  into _cantidad
  from emipouni
 where no_poliza = a_no_poliza 
   and activo = 1;	   --> Le agregue esta condicion Amado 2/8/2011 

if _cantidad > 1 then
	return 0, "Actualizacion Exitosa...";
end if

select max(periodo) 
  into _periodo
  from parcontrol;

foreach
	select cod_asegurado,
	       cod_producto,
	       prima_asegurado,
	       no_unidad,
	       cambiar_tarifas
	  into _cod_cliente, 
	       _cod_producto, 
	       _prima_total, 
		   _no_unidad,
		   _cambiar_tarifas
	  from emipouni
	 where no_poliza = a_no_poliza
	   and activo    = 1		 --> Le agregue esta condicion Amado 2/8/2011

	let _producto_nuevo = _cod_producto;

	select vigencia_inic,
	       vigencia_final,
		   cod_perpago,
		   cod_tipoprod,
		   no_documento,
		   cod_subramo,
		   cod_grupo
	  into _vigencia_inic,
	       _vigencia_final,
		   _cod_perpago,
		   _cod_tipoprod,
		   _no_documento,
		   _cod_subramo,
		   _cod_grupo
	  from emipomae
	 where no_poliza = a_no_poliza; 

	-- Verificacion si es Coaseguro Mayoritario

	IF _cod_tipoprod = "001" THEN

		SELECT porc_partic_coas
		  INTO _porc_coas
		  FROM emicoama
		 WHERE no_poliza    = _no_poliza
		   AND cod_coasegur = "036";

		IF _porc_coas IS NULL THEN
			LET _porc_coas = 100;
		END IF

	ELSE
		LET _porc_coas = 100;
	END IF

	select fecha_aniversario
	  into _fecha_nac
	  from cliclien
	 where cod_cliente = _cod_cliente;
 
	let _edad = sp_sis78(_fecha_nac, _vigencia_final);
	
	let _prima_plan   = 0;
	let _prima_vida   = 0;

  	let _cod_producto = sp_pro30l(a_no_poliza, _cod_producto); --  Se agrega para el cambio de tarifa 2023 del grupo FAES -- Amado Perez. 24/02/2023

    select tar_salud
	  into _tar_salud
	  from prdprod
	 where cod_producto = _cod_producto;
	 
	select prima,
           prima_vida
	  into _prima_plan,
           _prima_vida
	  from prdtaeda
	 where cod_producto = _cod_producto
	   and edad_desde   <= _edad
	   and edad_hasta   >= _edad;
	   
	--determinar si el asegurado tiene cambio de edad para insertar en tabla prdcameda     Armando 06/06/2024
	foreach
		SELECT edad_desde,
		       edad_hasta
		  INTO _edad_desde,
		       _edad_hasta
		  FROM prdtaeda
		 WHERE cod_producto = _cod_producto
		   and edad_desde > 0
	  order by edad_desde
	  
		if _edad = _edad_desde THEN	--Tiene cambio de edad
			insert into prdcameda(
			no_poliza,
			no_unidad,
			cod_producto,
			cod_cliente,
			edad_desde,
			edad_hasta,
			prima,			
			tipo_cliente,
			periodo
			)	
			values (
			a_no_poliza,
			_no_unidad,
			_cod_producto,
			_cod_cliente,
			_edad_desde,
			_edad_hasta,
			_prima_plan,     		 							
			'A',
			_periodo
			);
		end if
	end foreach

    let _tarifa_dep_tot	= 0;  

    if _tar_salud = 5 then	--> Tarifas por edad (Aseg + Dep)
		FOREACH with hold
			SELECT cod_cliente
			  INTO _cod_depend
			  FROM emidepen
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad
			   AND activo = 1

			SELECT fecha_aniversario
			  INTO _fecha_aniversario
			  FROM cliclien
			 WHERE cod_cliente = _cod_depend;

			LET _edad = sp_sis78(_fecha_aniversario, _vigencia_final);
			let _edad = _edad + 3;

			let _tarifa_dep     = 0;
			let _prima_plan_dep = 0;
			let _prima_vida_dep = 0;
			 
			select prima,
				   prima_vida
			  into _prima_plan_dep,
				   _prima_vida_dep
			  from prdtaeda
			 where cod_producto = _cod_producto
			   and edad_desde   <= _edad
			   and edad_hasta   >= _edad;

			if _prima_plan_dep is null then
				let _prima_plan_dep = 0;
			end if

			if _prima_vida_dep is null then
				let _prima_vida_dep = 0;
			end if

			let _tarifa_dep = _prima_plan_dep + _prima_vida_dep;

			let _tarifa_dep_tot	= _tarifa_dep_tot + _tarifa_dep;
			--determinar si el dependiente tiene cambio de edad para insertar en tabla prdcameda     Armando 06/06/2024
			foreach
				SELECT edad_desde,
					   edad_hasta
				  INTO _edad_desde,
					   _edad_hasta
				  FROM prdtaeda
				 WHERE cod_producto = _cod_producto
				   and edad_desde > 0
			  order by edad_desde
			  
			    if _edad = _edad_desde THEN	--Tiene cambio de edad
					insert into prdcameda(
					no_poliza,
					no_unidad,
					cod_producto,
					cod_cliente,
					edad_desde,
					edad_hasta,
					prima,			
					tipo_cliente,
					periodo
					)	
					values (
					a_no_poliza,
					_no_unidad,
					_cod_producto,
					_cod_depend,
					_edad_desde,
					_edad_hasta,
					_tarifa_dep,     		 							
					'D',
					_periodo
					);
				end if
			end foreach
		END FOREACH
		let _prima_plan = _prima_plan + _tarifa_dep_tot;
    end if
	set isolation to dirty read; --> cambiamos a dirty read para que no tranque Amado 4/10/2010      	
end foreach
end
return 0, "Actualizacion Exitosa...Final";
end procedure